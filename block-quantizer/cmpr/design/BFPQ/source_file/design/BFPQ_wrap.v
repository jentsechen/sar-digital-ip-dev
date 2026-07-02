module BFPQ_wrap #(
    //-----------parameter-----------------------------
    parameter NUMBLOCK_W = 16,
    parameter NUM_DATA_PATH = 4,
    parameter IQ = 2,
    parameter DSP_DATA_BITS = 16,
    parameter ADC_WORDLENGTH = 14,
    parameter BLOCKSIZEMOD_WRODLENGTH = 2, 
    parameter OUTPUT_WORDLENGTH = 14,
    parameter OUTPUTMOD_WORDLENGTH = 3,
    parameter PARALLEL_NUMBER = 4,
    parameter BFPQ_HEAD_W = 9,
    parameter BLOCK_SIZE_WORDLENGTH = 10
) (
    input clk,
    input rst,
    input [BLOCKSIZEMOD_WRODLENGTH-1:0]block_size_mode, //=BMOD
    input [OUTPUTMOD_WORDLENGTH-1:0]word_length_mode, //=MMOD

    input S_AXIS_IN_TVALID,
    output S_AXIS_IN_TREADY,
    input [NUM_DATA_PATH*IQ*DSP_DATA_BITS-1:0]S_AXIS_IN_TDATA,       
    input S_AXIS_IN_TLAST,     

    output M_AXIS_OUT_TVALID,
    input M_AXIS_OUT_TREADY,
    output [BFPQ_HEAD_W+PARALLEL_NUMBER*2*OUTPUT_WORDLENGTH-1:0]M_AXIS_OUT_TDATA,   
    output M_AXIS_OUT_TLAST  
    
);
localparam IDLE = 2'd0;
localparam COMPUTE = 2'd2;
localparam LAST_COMPUTE = 2'd3;

wire S_AXIS_IN_TREADY_TEMP;

reg [2-1:0]state_reg,state_next;

wire [ADC_WORDLENGTH-1:0] S2POUTI1, S2POUTI2, S2POUTI3, S2POUTI4, S2POUTQ1, S2POUTQ2, S2POUTQ3, S2POUTQ4;

wire clear = (state_reg == IDLE);

reg [5-1:0]output_delay;

reg [BLOCK_SIZE_WORDLENGTH-1:0]block_size_sample;

reg [5-1:0]out_last_cnt;

reg EnableIn;

wire [3-1:0]Ce,Cw;
wire [7-1:0]MantissaI1, MantissaI2, MantissaI3, MantissaI4, MantissaQ1, MantissaQ2, MantissaQ3, MantissaQ4;
wire SignI1, SignQ1, SignI2, SignQ2, SignI3, SignQ3, SignI4, SignQ4;
wire fOutValid, fBlockEnd;

reg [4-1:0]wordlength;

wire [BFPQ_HEAD_W+PARALLEL_NUMBER*2*OUTPUT_WORDLENGTH-1:0]out_fifo_data;

//----------input domain------------
assign S2POUTQ4 = S_AXIS_IN_TDATA[(2+7*16)+:14];
assign S2POUTI4 = S_AXIS_IN_TDATA[(2+6*16)+:14];
assign S2POUTQ3 = S_AXIS_IN_TDATA[(2+5*16)+:14];
assign S2POUTI3 = S_AXIS_IN_TDATA[(2+4*16)+:14];
assign S2POUTQ2 = S_AXIS_IN_TDATA[(2+3*16)+:14];
assign S2POUTI2 = S_AXIS_IN_TDATA[(2+2*16)+:14];
assign S2POUTQ1 = S_AXIS_IN_TDATA[(2+1*16)+:14];
assign S2POUTI1 = S_AXIS_IN_TDATA[(2+0*16)+:14];

assign S_AXIS_IN_TREADY_TEMP = ~prog_full & (fifo_ready || ~fOutValid);
assign S_AXIS_IN_TREADY = (state_reg == COMPUTE)?S_AXIS_IN_TREADY_TEMP:0;

always @(*) begin
	case(block_size_mode)
		2'd0: output_delay = 'd17;
		2'd1: output_delay = 'd19;
		2'd2: output_delay = 'd23;
		default: output_delay = 'd0;
	endcase
end

always @* begin
    case(block_size_mode)
        2'd0: block_size_sample = 'd2; //'d8/4
        2'd1: block_size_sample = 'd4; //'d16/4
        2'd2: block_size_sample = 'd8; //'d32/4
     default: block_size_sample = 'd0;
    endcase
end

bfpq_tlast_fifo u_bfpq_tlast_fifo (
  .clk(clk),                  // input wire clk
  .srst(rst),                // input wire srst
  .din(S_AXIS_IN_TLAST),                  // input wire [0 : 0] din
  .wr_en(S_AXIS_IN_TVALID && S_AXIS_IN_TREADY),              // input wire wr_en
  .rd_en(M_AXIS_OUT_TVALID && M_AXIS_OUT_TREADY),              // input wire rd_en
  .dout(M_AXIS_OUT_TLAST),                // output wire [0 : 0] dout
  .full(),                // output wire full
  .empty(),              // output wire empty
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
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
            EnableIn = S_AXIS_IN_TVALID;
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

assign out_fifo_data[7*14+:14] = (SignI1&((1<<8)-1))<<(wordlength-1)|MantissaI1;
assign out_fifo_data[6*14+:14] = (SignQ1&((1<<8)-1))<<(wordlength-1)|MantissaQ1;
assign out_fifo_data[5*14+:14] = (SignI2&((1<<8)-1))<<(wordlength-1)|MantissaI2;
assign out_fifo_data[4*14+:14] = (SignQ2&((1<<8)-1))<<(wordlength-1)|MantissaQ2;
assign out_fifo_data[3*14+:14] = (SignI3&((1<<8)-1))<<(wordlength-1)|MantissaI3;
assign out_fifo_data[2*14+:14] = (SignQ3&((1<<8)-1))<<(wordlength-1)|MantissaQ3;
assign out_fifo_data[1*14+:14] = (SignI4&((1<<8)-1))<<(wordlength-1)|MantissaI4;
assign out_fifo_data[0*14+:14] = (SignQ4&((1<<8)-1))<<(wordlength-1)|MantissaQ4;
assign out_fifo_data[PARALLEL_NUMBER*2*OUTPUT_WORDLENGTH+:BFPQ_HEAD_W] = {3'b0,Ce,Cw};

axis_BFPQ_out_fifo u_axis_BFPQ_out_fifo (
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


BFPQ_tunable_4way_v2 #(
    .ADC_WORDLENGTH(ADC_WORDLENGTH)
)u_BFPQ_tunable_4way_v2(
    .ClockBFPQ  (clk  ),
    .clear      (rst || clear     ),
    .BMOD       (block_size_mode       ),
    .MMOD       (word_length_mode       ),
    .EnableIn   (EnableIn   ),

    .S2POUTI1   (S2POUTI1   ),
    .S2POUTI2   (S2POUTI2   ),
    .S2POUTI3   (S2POUTI3   ),
    .S2POUTI4   (S2POUTI4   ),
    .S2POUTQ1   (S2POUTQ1   ),
    .S2POUTQ2   (S2POUTQ2   ),
    .S2POUTQ3   (S2POUTQ3   ),
    .S2POUTQ4   (S2POUTQ4   ),

    .Ce         (Ce         ),
    .Cw         (Cw         ),
    .MantissaI1 (MantissaI1 ),
    .MantissaI2 (MantissaI2 ),
    .MantissaI3 (MantissaI3 ),
    .MantissaI4 (MantissaI4 ),
    .MantissaQ1 (MantissaQ1 ),
    .MantissaQ2 (MantissaQ2 ),
    .MantissaQ3 (MantissaQ3 ),
    .MantissaQ4 (MantissaQ4 ),
    .SignI1     (SignI1     ),
    .SignQ1     (SignQ1     ),
    .SignI2     (SignI2     ),
    .SignQ2     (SignQ2     ),
    .SignI3     (SignI3     ),
    .SignQ3     (SignQ3     ),
    .SignI4     (SignI4     ),
    .SignQ4     (SignQ4     ),
    .fOutValid  (fOutValid  ),
    .fBlockEnd  (fBlockEnd_fifo  )
);


    
endmodule