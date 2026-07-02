`timescale 1ns / 1ps
`define CYCLE 10

module tb_BAQ_wrap;

//configurable
integer seed = 31;
localparam RANDOM_VALID = 1;
localparam RANDOM_READY = 1;
localparam KEEP_DATA = 0;//keep data 1 cycle after handshake
localparam TB_DIR = "../../../../../source_file/simulation/tb_BAQ_wrap/";
localparam INPUT_SAMPLES = 1600;
localparam PRI = 2;

localparam NMOD = 4;
localparam BSMOD = 0;
localparam SEGMOD = 0;

parameter NUMBLOCK_W = 16;
parameter NUM_DATA_PATH = 4;
parameter IQ = 2;
parameter DSP_DATA_BITS = 16;
parameter PARALLEL_NUMBER = 4;
parameter ADC_WORDLENGTH = 14;                //S2.11
parameter ADC_FRAC_WORDLENGTH = 11;
parameter OUTPUTMOD_WORDLENGTH = 3;           //N = 2 3 4 6 8
parameter THRESHOLD_NUMBER_W = 7;
parameter BLOCKSIZEMOD_WRODLENGTH = 2;        //Block_size = 128 256 512
parameter SEGMENTATIONMOD_WORDLENGTH = 1;     //Segmentation = 128 256
parameter VARIANCEADDRESS_WORDLENGTH = 8;     //Max Segmentation size = 256 -> 8 wordlength
parameter PARALLEL_BLOCK_SIZE_WORDLENGTH = 8; //4 parallel channel, maximum size = 512/4
parameter SQU_WORDLENGTH = 19;                //U5.14
parameter SQU_FRAC_WORDLENGTH = 14;
parameter ACC_WORDLENGTH = 29;                //U15.14
parameter SHIFT_WORDLENGTH = 8;               //U8.0
parameter SCALING_NUMBER = 256;
parameter SCALING_WORDLENGTH = 17;            //U6.9
parameter SCALING_FRAC_WORDLENGTH = 9;
parameter MULTI_WORDLENGTH = 14;              //S3.10
parameter MULTI_FRAC_WORDLENGTH = 10;
parameter THRESHOLD_NUMBER = 127;
parameter THRESHOLD_WORDLENGTH = 14;          //N = 2(S6.7) 3(S5.8) 4(S4.9) 6(S3.10) 8(S3.10)+
parameter THRES_FRAC_WORDLENGTH = 10;
parameter OUTPUT_WORDLENGTH = 8;              //For N = 2 3 4 6 8 
parameter BLOCK_SIZE_WORDLENGTH = 10;
parameter BAQ_HEAD_W = VARIANCEADDRESS_WORDLENGTH+1;
parameter TM_BRAM_NUM = 32;
parameter TM_DATA_CH = TM_BRAM_NUM*2;

localparam ST_DATA_NUM = 512;
localparam TM_DATA_NUM = 5*(127+1);

localparam BRAM_DEPTH = ST_DATA_NUM+TM_DATA_NUM;

localparam AXI_ADDR_W = $clog2(4*BRAM_DEPTH); //byte address
localparam AXI_DATA_W = 32;

//AXIL TO SP parameter
localparam SP_ADDR_W = $clog2(BRAM_DEPTH);
localparam SP_DATA_W = 32;

localparam IN_DATA_SHIFT = 2;

logic rst = 0;
logic clk = 1;

logic baq_sp_en;
logic baq_sp_wen;
logic [SP_ADDR_W-1:0] baq_sp_addr;
logic [SP_DATA_W-1:0]baq_sp_wdata;
logic [SP_DATA_W-1:0]baq_sp_rdata;


logic [BLOCKSIZEMOD_WRODLENGTH-1:0]block_size_mode;   
logic [OUTPUTMOD_WORDLENGTH-1:0]word_length_mode;  
logic [SEGMENTATIONMOD_WORDLENGTH-1:0]baq_seg_mode;
logic S_AXIS_IN_TVALID = 0;  
logic S_AXIS_IN_TREADY;  
logic [NUM_DATA_PATH*IQ*DSP_DATA_BITS-1:0]S_AXIS_IN_TDATA = 0;   
logic S_AXIS_IN_TLAST = 0;   
logic M_AXIS_OUT_TVALID; 
logic M_AXIS_OUT_TREADY=0; 
logic [BAQ_HEAD_W+PARALLEL_NUMBER*2*ADC_WORDLENGTH-1:0]M_AXIS_OUT_TDATA;  
logic M_AXIS_OUT_TLAST; 

//axi lite interface
axi4_lite_vinf #(
    .AXI_ADDR_W(AXI_ADDR_W),
    .AXI_DATA_W(AXI_DATA_W)
) axil_bram_controller_inf (
    .clk(clk)
);

axi_lite_to_sp #(
    .SP_ADDR_W(SP_ADDR_W)
)u_axi_lite_to_sp(
    .clk           (clk           ),
    .rst           (rst           ),

    .S_AXI_AWADDR        (axil_bram_controller_inf.AWADDR        ),
    .S_AXI_AWVALID       (axil_bram_controller_inf.AWVALID       ),
    .S_AXI_AWREADY       (axil_bram_controller_inf.AWREADY       ),
    .S_AXI_WDATA         (axil_bram_controller_inf.WDATA         ),
    .S_AXI_WVALID        (axil_bram_controller_inf.WVALID        ),
    .S_AXI_WREADY        (axil_bram_controller_inf.WREADY        ),
    .S_AXI_BRESP         (axil_bram_controller_inf.BRESP         ),
    .S_AXI_BVALID        (axil_bram_controller_inf.BVALID        ),
    .S_AXI_BREADY        (axil_bram_controller_inf.BREADY        ),
    .S_AXI_ARADDR        (axil_bram_controller_inf.ARADDR        ),
    .S_AXI_ARVALID       (axil_bram_controller_inf.ARVALID       ),
    .S_AXI_ARREADY       (axil_bram_controller_inf.ARREADY       ),
    .S_AXI_RDATA         (axil_bram_controller_inf.RDATA         ),
    .S_AXI_RRESP         (axil_bram_controller_inf.RRESP         ),
    .S_AXI_RVALID        (axil_bram_controller_inf.RVALID        ),
    .S_AXI_RREADY        (axil_bram_controller_inf.RREADY        ),

    .sp_en         (baq_sp_en         ),
    .sp_wen        (baq_sp_wen        ),
    .sp_addr       (baq_sp_addr       ),
    .sp_wdata      (baq_sp_wdata      ),
    .sp_rdata      (baq_sp_rdata      )
    
);

BAQ_wrap #(
    .NUMBLOCK_W(NUMBLOCK_W)
    ,.NUM_DATA_PATH(NUM_DATA_PATH)
    ,.IQ(IQ)
    ,.DSP_DATA_BITS(DSP_DATA_BITS)
    ,.PARALLEL_NUMBER(PARALLEL_NUMBER)
    ,.ADC_WORDLENGTH(ADC_WORDLENGTH)
    ,.ADC_FRAC_WORDLENGTH(ADC_FRAC_WORDLENGTH)
    ,.OUTPUTMOD_WORDLENGTH(OUTPUTMOD_WORDLENGTH)
    ,.THRESHOLD_NUMBER_W(THRESHOLD_NUMBER_W)
    ,.BLOCKSIZEMOD_WRODLENGTH(BLOCKSIZEMOD_WRODLENGTH)
    ,.SEGMENTATIONMOD_WORDLENGTH(SEGMENTATIONMOD_WORDLENGTH)
    ,.VARIANCEADDRESS_WORDLENGTH(VARIANCEADDRESS_WORDLENGTH)
    ,.PARALLEL_BLOCK_SIZE_WORDLENGTH(PARALLEL_BLOCK_SIZE_WORDLENGTH)
    ,.SQU_WORDLENGTH(SQU_WORDLENGTH)
    ,.SQU_FRAC_WORDLENGTH(SQU_FRAC_WORDLENGTH)
    ,.ACC_WORDLENGTH(ACC_WORDLENGTH)
    ,.SHIFT_WORDLENGTH(SHIFT_WORDLENGTH)
    ,.SCALING_NUMBER(SCALING_NUMBER)
    ,.SCALING_WORDLENGTH(SCALING_WORDLENGTH)
    ,.SCALING_FRAC_WORDLENGTH(SCALING_FRAC_WORDLENGTH)
    ,.MULTI_WORDLENGTH(MULTI_WORDLENGTH)
    ,.MULTI_FRAC_WORDLENGTH(MULTI_FRAC_WORDLENGTH)
    ,.THRESHOLD_NUMBER(THRESHOLD_NUMBER)
    ,.THRESHOLD_WORDLENGTH(THRESHOLD_WORDLENGTH)
    ,.THRES_FRAC_WORDLENGTH(THRES_FRAC_WORDLENGTH)
    ,.OUTPUT_WORDLENGTH(OUTPUT_WORDLENGTH)
    ,.BLOCK_SIZE_WORDLENGTH(BLOCK_SIZE_WORDLENGTH)
    ,.BAQ_HEAD_W(BAQ_HEAD_W)
    ,.TM_BRAM_NUM(TM_BRAM_NUM)
    ,.ST_DATA_NUM(ST_DATA_NUM)
    ,.TM_DATA_NUM(TM_DATA_NUM)
    ,.AXI_ADDR_W(AXI_ADDR_W)
    ,.IN_DATA_SHIFT(IN_DATA_SHIFT)
)u_BAQ_wrap(
    .clk                (clk                ),
    .rst                (rst                ),
    .block_size_mode    (block_size_mode    ),
    .word_length_mode   (word_length_mode   ),
    .baq_seg_mode       (baq_seg_mode       ),
    .S_AXIS_IN_TVALID   (S_AXIS_IN_TVALID   ),
    .S_AXIS_IN_TREADY   (S_AXIS_IN_TREADY   ),
    .S_AXIS_IN_TDATA    (S_AXIS_IN_TDATA    ),
    .S_AXIS_IN_TLAST    (S_AXIS_IN_TLAST    ),
    .M_AXIS_OUT_TVALID  (M_AXIS_OUT_TVALID  ),
    .M_AXIS_OUT_TREADY  (M_AXIS_OUT_TREADY  ),
    .M_AXIS_OUT_TDATA   (M_AXIS_OUT_TDATA   ),
    .M_AXIS_OUT_TLAST   (M_AXIS_OUT_TLAST   ),
    // .S_AXI_BRAM_AWADDR  (axil_bram_controller_inf.AWADDR  ),
    // .S_AXI_BRAM_AWVALID (axil_bram_controller_inf.AWVALID ),
    // .S_AXI_BRAM_AWREADY (axil_bram_controller_inf.AWREADY ),
    // .S_AXI_BRAM_WDATA   (axil_bram_controller_inf.WDATA   ),
    // .S_AXI_BRAM_WVALID  (axil_bram_controller_inf.WVALID  ),
    // .S_AXI_BRAM_WREADY  (axil_bram_controller_inf.WREADY  ),
    // .S_AXI_BRAM_BRESP   (axil_bram_controller_inf.BRESP   ),
    // .S_AXI_BRAM_BVALID  (axil_bram_controller_inf.BVALID  ),
    // .S_AXI_BRAM_BREADY  (axil_bram_controller_inf.BREADY  ),
    // .S_AXI_BRAM_ARADDR  (axil_bram_controller_inf.ARADDR  ),
    // .S_AXI_BRAM_ARVALID (axil_bram_controller_inf.ARVALID ),
    // .S_AXI_BRAM_ARREADY (axil_bram_controller_inf.ARREADY ),
    // .S_AXI_BRAM_RDATA   (axil_bram_controller_inf.RDATA   ),
    // .S_AXI_BRAM_RRESP   (axil_bram_controller_inf.RRESP   ),
    // .S_AXI_BRAM_RVALID  (axil_bram_controller_inf.RVALID  ),
    // .S_AXI_BRAM_RREADY  (axil_bram_controller_inf.RREADY  )
    .baq_sp_en         (baq_sp_en         ),
    .baq_sp_wen        (baq_sp_wen        ),
    .baq_sp_addr       (baq_sp_addr       ),
    .baq_sp_wdata      (baq_sp_wdata      ),
    .baq_sp_rdata      (baq_sp_rdata      )
);

always #(`CYCLE/2) clk = ~clk;

logic  [AXI_DATA_W-1:0] bram_init_data [ST_DATA_NUM+TM_DATA_NUM];
initial $readmemb($sformatf("%s%s",TB_DIR,"../bram_init_data.mem"),bram_init_data);

logic [DSP_DATA_BITS-1:0] test_pat [INPUT_SAMPLES*PARALLEL_NUMBER*IQ];//num_block*block_size*iq
initial $readmemb($sformatf("%s%s",TB_DIR,"../tb_BAQ_4way/test_pat.mem"),test_pat);

task sync_reset;
    rst <= 1'b0;
    repeat(1) @(posedge clk);
    rst <= 1'b1;
    repeat(1) @(posedge clk);
    rst <= 1'b0;
    repeat(1) @(posedge clk);
endtask


task automatic run_pattern();
    @(negedge clk);
    S_AXIS_IN_TVALID = 1'b1;
    repeat(PRI)begin
        for (int i = 0; i < INPUT_SAMPLES; i++) begin //(num_block*block_size)/parallel_num
        S_AXIS_IN_TDATA = {test_pat[i*8+7]<<2,
                        test_pat[i*8+6]<<2,
                        test_pat[i*8+5]<<2,
                        test_pat[i*8+4]<<2,
                        test_pat[i*8+3]<<2,
                        test_pat[i*8+2]<<2,
                        test_pat[i*8+1]<<2,
                        test_pat[i*8+0]<<2};//{Q4,I4,Q3,I3,Q2,I2,Q1,I1}   
        S_AXIS_IN_TLAST = (i == INPUT_SAMPLES-1);
        if(RANDOM_VALID) S_AXIS_IN_TVALID=$random(seed);  
        else S_AXIS_IN_TVALID=1;
        while(~S_AXIS_IN_TVALID)begin
            @(negedge clk);
            S_AXIS_IN_TVALID=$random(seed);
        end
        while(~S_AXIS_IN_TREADY)@(posedge clk);
        @(negedge clk);
        //optional: keep data 1 cycle after handshake
        if(KEEP_DATA)begin
            S_AXIS_IN_TVALID=0;
            repeat(1)@(negedge clk);
        end
        end
        S_AXIS_IN_TVALID=0;
    end
endtask

int read_data;
initial begin
    axil_bram_controller_inf.init_master();
    sync_reset;

    block_size_mode=BSMOD;
    word_length_mode=NMOD;
    baq_seg_mode=SEGMOD;

    //Write bram init data
    for (int i = 0;i<ST_DATA_NUM+TM_DATA_NUM ; i++) axil_bram_controller_inf.write(4*i,bram_init_data[i]);
    //Read bram init data
    for (int i = 0;i<ST_DATA_NUM+TM_DATA_NUM ; i++) begin
        axil_bram_controller_inf.read(4*i,read_data);
        $display("AXIL Read addr: %0d , data: %0h",i,read_data);
    end
    //LOAD INIT DONE
    axil_bram_controller_inf.write(4*(ST_DATA_NUM+TM_DATA_NUM),1);

    run_pattern;

    repeat(10240)@(posedge clk);

    $finish;
end



always_ff @( posedge clk ) begin : rand_rdy
    if(RANDOM_READY) begin
        M_AXIS_OUT_TREADY <= $random(seed);    
    end else begin
        M_AXIS_OUT_TREADY <= 1;
    end
end

integer i; 
integer Result_I1, Result_Q1;
integer Result_I2, Result_Q2;
integer Result_I3, Result_Q3;
integer Result_I4, Result_Q4;
integer Result_header;  

initial begin
    $system($sformatf("rm -rf %soutput/",TB_DIR));
    $system($sformatf("mkdir %soutput/",TB_DIR));
    Result_I1 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_I1.txt"));
    Result_I2 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_I2.txt"));
    Result_I3 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_I3.txt"));
    Result_I4 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_I4.txt"));
    Result_Q1 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_Q1.txt"));
    Result_Q2 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_Q2.txt"));
    Result_Q3 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_Q3.txt"));
    Result_Q4 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_Q4.txt"));
    Result_header = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_header.txt"));
                
    for(i=0; i <10000000; i= i +1) begin 
        if(M_AXIS_OUT_TREADY && M_AXIS_OUT_TVALID)  begin  
            $fdisplay(Result_I1,"%0d ", M_AXIS_OUT_TDATA[7*14+:14]);
            $fdisplay(Result_Q1,"%0d ", M_AXIS_OUT_TDATA[6*14+:14]);
            $fdisplay(Result_I2,"%0d ", M_AXIS_OUT_TDATA[5*14+:14]);
            $fdisplay(Result_Q2,"%0d ", M_AXIS_OUT_TDATA[4*14+:14]);
            $fdisplay(Result_I3,"%0d ", M_AXIS_OUT_TDATA[3*14+:14]);
            $fdisplay(Result_Q3,"%0d ", M_AXIS_OUT_TDATA[2*14+:14]);
            $fdisplay(Result_I4,"%0d ", M_AXIS_OUT_TDATA[1*14+:14]);
            $fdisplay(Result_Q4,"%0d ", M_AXIS_OUT_TDATA[0*14+:14]);
            if(u_BAQ_wrap.fBlockEnd==1'b1) begin
                $fdisplay(Result_header,"%d ", M_AXIS_OUT_TDATA[PARALLEL_NUMBER*2*ADC_WORDLENGTH+:BAQ_HEAD_W]);
            end
        end
        #(`CYCLE);
    end
    $fclose(Result_I1);
    $fclose(Result_I2);
    $fclose(Result_I3);
    $fclose(Result_I4);
    $fclose(Result_Q1);
    $fclose(Result_Q2);
    $fclose(Result_Q3);
    $fclose(Result_Q4);

    $fclose(Result_header);
end

endmodule