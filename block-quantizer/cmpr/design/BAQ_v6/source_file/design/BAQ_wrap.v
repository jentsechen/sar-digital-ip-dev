module BAQ_wrap #(
    //-----------parameter-----------------------------
    parameter NUMBLOCK_W = 16,
    parameter NUM_DATA_PATH = 4,
    parameter IQ = 2,
    parameter DSP_DATA_BITS = 16,
    parameter PARALLEL_NUMBER = 4,
    parameter ADC_WORDLENGTH = 14,                //S2.11
    parameter ADC_FRAC_WORDLENGTH = 11,
    parameter OUTPUTMOD_WORDLENGTH = 3,           //N = 2 3 4 6 8
    parameter THRESHOLD_NUMBER_W = 7,
    parameter BLOCKSIZEMOD_WRODLENGTH = 2,        //Block_size = 128 256 512
    parameter SEGMENTATIONMOD_WORDLENGTH = 1,     //Segmentation = 128 256
    parameter VARIANCEADDRESS_WORDLENGTH = 8,     //Max Segmentation size = 256 -> 8 wordlength
    parameter PARALLEL_BLOCK_SIZE_WORDLENGTH = 8, //4 parallel channel, maximum size = 512/4
    parameter SQU_WORDLENGTH = 19,                //U5.14
    parameter SQU_FRAC_WORDLENGTH = 14,
    parameter ACC_WORDLENGTH = 29,                //U15.14
    parameter SHIFT_WORDLENGTH = 8,               //U8.0
    parameter SCALING_NUMBER = 256,
    parameter SCALING_WORDLENGTH = 17,            //U6.9
    parameter SCALING_FRAC_WORDLENGTH = 9,
    parameter MULTI_WORDLENGTH = 14,              //S3.10
    parameter MULTI_FRAC_WORDLENGTH = 10,
    parameter THRESHOLD_NUMBER = 127,
    parameter THRESHOLD_WORDLENGTH = 14,          //N = 2(S6.7) 3(S5.8) 4(S4.9) 6(S3.10) 8(S3.10)+
    parameter THRES_FRAC_WORDLENGTH = 10,
    parameter OUTPUT_WORDLENGTH = 8,              //For N = 2 3 4 6 8 
    parameter BLOCK_SIZE_WORDLENGTH = 10,
    parameter BAQ_HEAD_W = VARIANCEADDRESS_WORDLENGTH+1,

    parameter TM_BRAM_NUM = 32,
    parameter ST_DATA_NUM = 512,
    parameter TM_DATA_NUM = 5*(127+1),
    localparam BRAM_DEPTH = ST_DATA_NUM+TM_DATA_NUM,

    // //AXIL parameter
    // parameter AXI_ADDR_W = $clog2(4*BRAM_DEPTH), //byte address
    // localparam AXI_DATA_W = 32,

    //AXIL TO SP parameter
    localparam SP_ADDR_W = $clog2(BRAM_DEPTH),
    localparam SP_DATA_W = 32,

    parameter IN_DATA_SHIFT = 2
) (
    input clk,
    input rst,

    input [BLOCKSIZEMOD_WRODLENGTH-1:0]block_size_mode, //=BSMOD
    input [OUTPUTMOD_WORDLENGTH-1:0]word_length_mode, //=NMOD
    input [SEGMENTATIONMOD_WORDLENGTH-1:0]baq_seg_mode,

    input S_AXIS_IN_TVALID,
    output S_AXIS_IN_TREADY,
    input [NUM_DATA_PATH*IQ*DSP_DATA_BITS-1:0]S_AXIS_IN_TDATA,     
    input S_AXIS_IN_TLAST,       

    output M_AXIS_OUT_TVALID,
    input M_AXIS_OUT_TREADY,
    output [BAQ_HEAD_W+PARALLEL_NUMBER*IQ*ADC_WORDLENGTH-1:0]M_AXIS_OUT_TDATA, 
    output M_AXIS_OUT_TLAST, 

    // // BRAM INIT DATA AXIL IO
    // //WADDR
    // input [AXI_ADDR_W-1:0] S_AXI_BRAM_AWADDR,
    // input S_AXI_BRAM_AWVALID,
    // output S_AXI_BRAM_AWREADY,
    // //WDATA
    // input [AXI_DATA_W-1:0] S_AXI_BRAM_WDATA,
    // input S_AXI_BRAM_WVALID,
    // output S_AXI_BRAM_WREADY,
    // //BRESP
    // output [1:0] S_AXI_BRAM_BRESP,
    // output S_AXI_BRAM_BVALID,
    // input S_AXI_BRAM_BREADY,
    // //ARADDR
    // input [AXI_ADDR_W-1:0] S_AXI_BRAM_ARADDR,
    // input S_AXI_BRAM_ARVALID,
    // output S_AXI_BRAM_ARREADY,
    // //RDATA
    // output [AXI_DATA_W-1:0] S_AXI_BRAM_RDATA,
    // output [1:0] S_AXI_BRAM_RRESP,
    // output S_AXI_BRAM_RVALID,
    // input S_AXI_BRAM_RREADY

    /********AXIL TO SP IO*******/
    input baq_sp_en,
    input baq_sp_wen,
    input [SP_ADDR_W-1:0] baq_sp_addr,  // 32-bits word address, instead of byte address
    input [SP_DATA_W-1:0] baq_sp_wdata,
    output [SP_DATA_W-1:0] baq_sp_rdata
);
localparam IDLE = 2'd0;
localparam COMPUTE = 2'd1;
localparam LAST_COMPUTE = 2'd2;

wire S_AXIS_IN_TREADY_TEMP;

wire [ADC_WORDLENGTH-1:0] InputI0, InputI1, InputI2, InputI3, InputQ0, InputQ1, InputQ2, InputQ3;

reg [2-1:0]state_reg,state_next;

wire clear = (state_reg == IDLE);

reg [8-1:0]out_last_cnt;
reg EnableIn;

wire fifo_ready,prog_full;

reg [8-1:0]output_delay;
reg [BLOCK_SIZE_WORDLENGTH-1:0]block_size_sample;

wire [BAQ_HEAD_W+PARALLEL_NUMBER*IQ*ADC_WORDLENGTH-1:0]out_fifo_data;

reg [4-1:0]wordlength;

wire [OUTPUT_WORDLENGTH-1:0]BAQOutI0,BAQOutQ0; 
wire [OUTPUT_WORDLENGTH-1:0]BAQOutI1,BAQOutQ1;
wire [OUTPUT_WORDLENGTH-1:0]BAQOutI2,BAQOutQ2;
wire [OUTPUT_WORDLENGTH-1:0]BAQOutI3,BAQOutQ3;
wire [OUTPUT_WORDLENGTH-1:0]FVarianceAddress;
wire fOutValid;
wire fBlockEnd,fBlockEnd_fifo;
wire fOverFlow;  


//----------input domain------------
assign InputQ3 = S_AXIS_IN_TDATA[7*DSP_DATA_BITS+:DSP_DATA_BITS]>>IN_DATA_SHIFT;
assign InputI3 = S_AXIS_IN_TDATA[6*DSP_DATA_BITS+:DSP_DATA_BITS]>>IN_DATA_SHIFT;
assign InputQ2 = S_AXIS_IN_TDATA[5*DSP_DATA_BITS+:DSP_DATA_BITS]>>IN_DATA_SHIFT;
assign InputI2 = S_AXIS_IN_TDATA[4*DSP_DATA_BITS+:DSP_DATA_BITS]>>IN_DATA_SHIFT;
assign InputQ1 = S_AXIS_IN_TDATA[3*DSP_DATA_BITS+:DSP_DATA_BITS]>>IN_DATA_SHIFT;
assign InputI1 = S_AXIS_IN_TDATA[2*DSP_DATA_BITS+:DSP_DATA_BITS]>>IN_DATA_SHIFT;
assign InputQ0 = S_AXIS_IN_TDATA[1*DSP_DATA_BITS+:DSP_DATA_BITS]>>IN_DATA_SHIFT;
assign InputI0 = S_AXIS_IN_TDATA[0*DSP_DATA_BITS+:DSP_DATA_BITS]>>IN_DATA_SHIFT;

assign S_AXIS_IN_TREADY_TEMP = ~prog_full & (fifo_ready || ~fOutValid);
assign S_AXIS_IN_TREADY = (state_reg == COMPUTE)?S_AXIS_IN_TREADY_TEMP:0;

always @(*) begin
	case(block_size_mode)
		2'd0: output_delay = 'd51;
		2'd1: output_delay = 'd83;
		2'd2: output_delay = 'd147;
		default: output_delay = 'd0;
	endcase
end

always @* begin
    case(block_size_mode)
        2'd0: block_size_sample = 'd32; //'d128/4
        2'd1: block_size_sample = 'd64; //'d256/4
        2'd2: block_size_sample = 'd128; //'d512/4
     default: block_size_sample = 'd0;
    endcase
end

baq_tlast_fifo u_baq_tlast_fifo (
  .clk(clk),                                      // input wire clk
  .srst(rst),                                     // input wire srst
  .din(S_AXIS_IN_TLAST),                          // input wire [0 : 0] din
  .wr_en(S_AXIS_IN_TVALID && S_AXIS_IN_TREADY),   // input wire wr_en
  .rd_en(M_AXIS_OUT_TVALID && M_AXIS_OUT_TREADY), // input wire rd_en
  .dout(M_AXIS_OUT_TLAST),                        // output wire [0 : 0] dout
  .full(),                                        // output wire full
  .empty(),                                       // output wire empty
  .wr_rst_busy(),                                 // output wire wr_rst_busy
  .rd_rst_busy()                                  // output wire rd_rst_busy
);

always @(posedge clk) begin
    if (rst || clear) begin
        out_last_cnt <= 0;
    end else begin
        if(state_reg == LAST_COMPUTE)begin
            if(out_last_cnt<output_delay-1)begin
                out_last_cnt <= (S_AXIS_IN_TREADY_TEMP)?out_last_cnt+1:out_last_cnt;
            end else begin
                out_last_cnt <= out_last_cnt;
            end
        end else begin
            out_last_cnt <= 0;
        end
    end
end


always @( *) begin
    EnableIn = 0;
    case (state_reg)
        IDLE:begin
            EnableIn = 0;
        end
        COMPUTE:begin
            EnableIn = S_AXIS_IN_TVALID & S_AXIS_IN_TREADY;
        end
        LAST_COMPUTE:begin
            EnableIn = (out_last_cnt<output_delay-2)?S_AXIS_IN_TREADY_TEMP:0;
        end
    endcase
end


//----------output domain------------

always @(*) begin
	case(word_length_mode)
		3'd0: wordlength = 'd2;
		3'd1: wordlength = 'd3;
		3'd2: wordlength = 'd4;
		3'd3: wordlength = 'd6;
		3'd4: wordlength = 'd8;
		default: wordlength = 'd0;
	endcase
end


assign out_fifo_data[7*14+:14] = BAQOutI0;
assign out_fifo_data[6*14+:14] = BAQOutQ0;
assign out_fifo_data[5*14+:14] = BAQOutI1;
assign out_fifo_data[4*14+:14] = BAQOutQ1;
assign out_fifo_data[3*14+:14] = BAQOutI2;
assign out_fifo_data[2*14+:14] = BAQOutQ2;
assign out_fifo_data[1*14+:14] = BAQOutI3;
assign out_fifo_data[0*14+:14] = BAQOutQ3;
assign out_fifo_data[PARALLEL_NUMBER*IQ*ADC_WORDLENGTH+:BAQ_HEAD_W] = {FVarianceAddress, fOverFlow};

axis_BAQ_out_fifo u_axis_BAQ_out_fifo (
  .s_axis_aresetn(~rst || ~clear),  // input wire s_axis_aresetn
  .s_axis_aclk(clk),        // input wire s_axis_aclk
  .s_axis_tvalid(fOutValid),    // input wire s_axis_tvalid
  .s_axis_tready(fifo_ready),    // output wire s_axis_tready
  .s_axis_tdata({fBlockEnd_fifo,out_fifo_data}),      // input wire [127 : 0] s_axis_tdata
  .m_axis_tvalid(M_AXIS_OUT_TVALID),    // output wire m_axis_tvalid
  .m_axis_tready(M_AXIS_OUT_TREADY),    // input wire m_axis_tready
  .m_axis_tdata({fBlockEnd,M_AXIS_OUT_TDATA}),      // output wire [127 : 0] m_axis_tdata
  .prog_full(prog_full)            // output wire prog_full
);

//----------FSM control------------
always @( *) begin
    state_next = IDLE;
    case(state_reg)
        IDLE:begin
            state_next = COMPUTE;
        end
        COMPUTE:begin
            state_next = COMPUTE;
            if(S_AXIS_IN_TLAST & S_AXIS_IN_TVALID & S_AXIS_IN_TREADY) begin
                state_next = LAST_COMPUTE;
            end
        end
        LAST_COMPUTE:begin
            state_next = LAST_COMPUTE;
            if(M_AXIS_OUT_TLAST)begin
                state_next = IDLE;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= IDLE;
    end else begin
        state_reg <= state_next;
    end
end


//----------module instantiation------------
BAQ_4way #(
    .PARALLEL_NUMBER(PARALLEL_NUMBER)
    ,.THRESHOLD_NUMBER(THRESHOLD_NUMBER)
    ,.ADC_WORDLENGTH(ADC_WORDLENGTH)
    ,.ADC_FRAC_WORDLENGTH(ADC_FRAC_WORDLENGTH)
    ,.OUTPUTMOD_WORDLENGTH(OUTPUTMOD_WORDLENGTH)
    ,.BLOCKSIZEMOD_WRODLENGTH(BLOCKSIZEMOD_WRODLENGTH)
    ,.SEGMENTATIONMOD_WORDLENGTH(SEGMENTATIONMOD_WORDLENGTH)
    ,.VARIANCEADDRESS_WORDLENGTH(VARIANCEADDRESS_WORDLENGTH)
    ,.PARALLEL_BLOCK_SIZE_WORDLENGTH(PARALLEL_BLOCK_SIZE_WORDLENGTH)
    ,.SQU_WORDLENGTH(SQU_WORDLENGTH)
    ,.SQU_FRAC_WORDLENGTH(SQU_FRAC_WORDLENGTH)
    ,.ACC_WORDLENGTH(ACC_WORDLENGTH)
    ,.SHIFT_WORDLENGTH(SHIFT_WORDLENGTH)
    ,.SCALING_WORDLENGTH(SCALING_WORDLENGTH)
    ,.SCALING_FRAC_WORDLENGTH(SCALING_FRAC_WORDLENGTH)
    ,.MULTI_WORDLENGTH(MULTI_WORDLENGTH)
    ,.MULTI_FRAC_WORDLENGTH(MULTI_FRAC_WORDLENGTH)
    ,.THRESHOLD_WORDLENGTH(THRESHOLD_WORDLENGTH)
    ,.THRES_FRAC_WORDLENGTH(THRES_FRAC_WORDLENGTH)
    ,.OUTPUT_WORDLENGTH(OUTPUT_WORDLENGTH)

    ,.TM_BRAM_NUM(TM_BRAM_NUM)
    ,.ST_DATA_NUM(ST_DATA_NUM)
    ,.TM_DATA_NUM(TM_DATA_NUM)
    // ,.AXI_ADDR_W(AXI_ADDR_W)
)u_BAQ_4way(
    .clk              (clk             ),
    .rst              (rst||clear      ),
    .bram_ctrl_rst    (rst             ),

    .NMOD             (word_length_mode),
    .BSMOD            (block_size_mode ),
    .SEGMOD           (baq_seg_mode    ),

    .EnableIn         (EnableIn        ),
    .InputI0          (InputI0         ),
    .InputQ0          (InputQ0         ),
    .InputI1          (InputI1         ),
    .InputQ1          (InputQ1         ),
    .InputI2          (InputI2         ),
    .InputQ2          (InputQ2         ),
    .InputI3          (InputI3         ),
    .InputQ3          (InputQ3         ),

    .fOutValid        (fOutValid       ),
    .fOverFlow        (fOverFlow       ),
    .FVarianceAddress (FVarianceAddress),
    .BAQOutI0         (BAQOutI0        ),
    .BAQOutQ0         (BAQOutQ0        ),
    .BAQOutI1         (BAQOutI1        ),
    .BAQOutQ1         (BAQOutQ1        ),
    .BAQOutI2         (BAQOutI2        ),
    .BAQOutQ2         (BAQOutQ2        ),
    .BAQOutI3         (BAQOutI3        ),
    .BAQOutQ3         (BAQOutQ3        ), 
    .fBlockEnd        (fBlockEnd_fifo  ),

    // .S_AXI_AWADDR     (S_AXI_BRAM_AWADDR  ),
    // .S_AXI_AWVALID    (S_AXI_BRAM_AWVALID ),
    // .S_AXI_AWREADY    (S_AXI_BRAM_AWREADY ),
    // .S_AXI_WDATA      (S_AXI_BRAM_WDATA   ),
    // .S_AXI_WVALID     (S_AXI_BRAM_WVALID  ),
    // .S_AXI_WREADY     (S_AXI_BRAM_WREADY  ),
    // .S_AXI_BRESP      (S_AXI_BRAM_BRESP   ),
    // .S_AXI_BVALID     (S_AXI_BRAM_BVALID  ),
    // .S_AXI_BREADY     (S_AXI_BRAM_BREADY  ),
    // .S_AXI_ARADDR     (S_AXI_BRAM_ARADDR  ),
    // .S_AXI_ARVALID    (S_AXI_BRAM_ARVALID ),
    // .S_AXI_ARREADY    (S_AXI_BRAM_ARREADY ),
    // .S_AXI_RDATA      (S_AXI_BRAM_RDATA   ),
    // .S_AXI_RRESP      (S_AXI_BRAM_RRESP   ),
    // .S_AXI_RVALID     (S_AXI_BRAM_RVALID  ),
    // .S_AXI_RREADY     (S_AXI_BRAM_RREADY  )

    .sp_en         (baq_sp_en     ),
    .sp_wen        (baq_sp_wen    ),
    .sp_addr       (baq_sp_addr   ),
    .sp_wdata      (baq_sp_wdata  ),
    .sp_rdata      (baq_sp_rdata  )
);

    
endmodule