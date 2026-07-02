`timescale 1ns / 1ps
`define CYCLE 10


module tb_BAQ_4way;   

integer seed = 0;
parameter INPUT_SAMPLES = 1600;
parameter RANDOM_EnableIn = 0;
parameter TB_DIR = "../../../../../source_file/simulation/tb_BAQ_4way/";

parameter PARALLEL_NUMBER = 4;
parameter IQ = 2;


parameter THRESHOLD_NUMBER = 127;
parameter ADC_WORDLENGTH = 14;                //S2.11
parameter ADC_FRAC_WORDLENGTH = 11;
parameter OUTPUTMOD_WORDLENGTH = 3;           //N = 2 3 4 6 8
parameter BLOCKSIZEMOD_WRODLENGTH = 2;        //Block_size = 128 256 512
parameter SEGMENTATIONMOD_WORDLENGTH = 1;     //Segmentation = 128 256
parameter VARIANCEADDRESS_WORDLENGTH = 8;     //Max Segmentation size = 256 -> 8 wordlength
parameter PARALLEL_BLOCK_SIZE_WORDLENGTH = 8; //4 parallel channel and maximum size = 512/4
parameter SQU_WORDLENGTH = 19;                //U5.14
parameter SQU_FRAC_WORDLENGTH = 14;
parameter ACC_WORDLENGTH = 29;                //U15.14
parameter SHIFT_WORDLENGTH = 8;               //U8.0
parameter SCALING_WORDLENGTH = 17;            //U6.9
parameter SCALING_FRAC_WORDLENGTH = 9;
parameter MULTI_WORDLENGTH = 14;              //S3.10
parameter MULTI_FRAC_WORDLENGTH = 10;
parameter THRESHOLD_WORDLENGTH = 14;          //N = 2(S6.7) 3(S5.8) 4(S4.9) 6(S3.10) 8(S3.10)
parameter THRES_FRAC_WORDLENGTH = 10;
parameter OUTPUT_WORDLENGTH = 8;              //For N = 2 3 4 6 8 

localparam TM_BRAM_NUM = 32;

localparam ST_DATA_NUM = 512;
localparam TM_DATA_NUM = 5*(127+1);

localparam BRAM_DEPTH = ST_DATA_NUM+TM_DATA_NUM;

localparam AXI_ADDR_W = $clog2(4*BRAM_DEPTH); //byte address
localparam AXI_DATA_W = 32;

//AXIL TO SP parameter
localparam SP_ADDR_W = $clog2(BRAM_DEPTH);
localparam SP_DATA_W = 32;

logic  signed[ADC_WORDLENGTH-1:0] InputI0,InputI1,InputI2,InputI3;  
logic  signed[ADC_WORDLENGTH-1:0] InputQ0,InputQ1,InputQ2,InputQ3;  
logic  EnableIn = 0;
logic  rst = 0;
logic  clk = 1;
logic  [OUTPUTMOD_WORDLENGTH-1:0]NMOD;
logic  [BLOCKSIZEMOD_WRODLENGTH-1:0]BSMOD; 
logic  [SEGMENTATIONMOD_WORDLENGTH-1:0]SEGMOD;

logic [OUTPUT_WORDLENGTH-1:0]BAQOutI0,BAQOutQ0; 
logic [OUTPUT_WORDLENGTH-1:0]BAQOutI1,BAQOutQ1;
logic [OUTPUT_WORDLENGTH-1:0]BAQOutI2,BAQOutQ2;
logic [OUTPUT_WORDLENGTH-1:0]BAQOutI3,BAQOutQ3;
logic [OUTPUT_WORDLENGTH-1:0]FVarianceAddress;
logic fOutValid;
logic fBlockEnd;
logic fOverFlow;  

// //axil IO
// logic [AXI_ADDR_W-1:0] S_AXI_AWADDR;
// logic S_AXI_AWVALID=0;
// logic S_AXI_AWREADY;
// logic [AXI_DATA_W-1:0] S_AXI_WDATA;
// logic S_AXI_WVALID=0;
// logic S_AXI_WREADY;
// logic [1:0] S_AXI_BRESP;
// logic S_AXI_BVALID;
// logic S_AXI_BREADY=1;
// logic [AXI_ADDR_W-1:0] S_AXI_ARADDR;
// logic S_AXI_ARVALID=0;
// logic S_AXI_ARREADY;
// logic [AXI_DATA_W-1:0] S_AXI_RDATA;
// logic [1:0] S_AXI_RRESP;
// logic S_AXI_RVALID;
// logic S_AXI_RREADY=0;

logic baq_sp_en;
logic baq_sp_wen;
logic [SP_ADDR_W-1:0] baq_sp_addr;
logic [SP_DATA_W-1:0]baq_sp_wdata;
logic [SP_DATA_W-1:0]baq_sp_rdata;

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
    ,.AXI_ADDR_W(AXI_ADDR_W)
)uut(
    .clk(clk),
    .rst(rst),
    .bram_ctrl_rst(rst),
    .NMOD(NMOD),
    .BSMOD(BSMOD),
    .SEGMOD(SEGMOD),
    .EnableIn(EnableIn),
    .InputI0(InputI0),
    .InputQ0(InputQ0),
    .InputI1(InputI1),
    .InputQ1(InputQ1),
    .InputI2(InputI2),
    .InputQ2(InputQ2),
    .InputI3(InputI3),
    .InputQ3(InputQ3),
    .FVarianceAddress(FVarianceAddress),
    .fOutValid(fOutValid),
    .fOverFlow(fOverFlow),
    .fBlockEnd(fBlockEnd),
    .BAQOutI0(BAQOutI0),
    .BAQOutQ0(BAQOutQ0),
    .BAQOutI1(BAQOutI1),
    .BAQOutQ1(BAQOutQ1),
    .BAQOutI2(BAQOutI2),
    .BAQOutQ2(BAQOutQ2),
    .BAQOutI3(BAQOutI3),
    .BAQOutQ3(BAQOutQ3), 

    // .S_AXI_AWADDR        (axil_bram_controller_inf.AWADDR        ),
    // .S_AXI_AWVALID       (axil_bram_controller_inf.AWVALID       ),
    // .S_AXI_AWREADY       (axil_bram_controller_inf.AWREADY       ),
    // .S_AXI_WDATA         (axil_bram_controller_inf.WDATA         ),
    // .S_AXI_WVALID        (axil_bram_controller_inf.WVALID        ),
    // .S_AXI_WREADY        (axil_bram_controller_inf.WREADY        ),
    // .S_AXI_BRESP         (axil_bram_controller_inf.BRESP         ),
    // .S_AXI_BVALID        (axil_bram_controller_inf.BVALID        ),
    // .S_AXI_BREADY        (axil_bram_controller_inf.BREADY        ),
    // .S_AXI_ARADDR        (axil_bram_controller_inf.ARADDR        ),
    // .S_AXI_ARVALID       (axil_bram_controller_inf.ARVALID       ),
    // .S_AXI_ARREADY       (axil_bram_controller_inf.ARREADY       ),
    // .S_AXI_RDATA         (axil_bram_controller_inf.RDATA         ),
    // .S_AXI_RRESP         (axil_bram_controller_inf.RRESP         ),
    // .S_AXI_RVALID        (axil_bram_controller_inf.RVALID        ),
    // .S_AXI_RREADY        (axil_bram_controller_inf.RREADY        )

    .sp_en         (baq_sp_en         ),
    .sp_wen        (baq_sp_wen        ),
    .sp_addr       (baq_sp_addr       ),
    .sp_wdata      (baq_sp_wdata      ),
    .sp_rdata      (baq_sp_rdata      )
);

always #(`CYCLE/2) clk = ~clk;


logic  [AXI_DATA_W-1:0] bram_init_data [ST_DATA_NUM+TM_DATA_NUM];
initial $readmemb($sformatf("%s%s",TB_DIR,"../bram_init_data.mem"),bram_init_data);

logic [ADC_WORDLENGTH-1:0] test_pat [INPUT_SAMPLES*PARALLEL_NUMBER*IQ];//num_block*block_size*iq
initial $readmemb($sformatf("%s%s",TB_DIR,"test_pat.mem"),test_pat);


task sync_reset;
    rst <= 1'b0;
    repeat(1) @(posedge clk);
    rst <= 1'b1;
    repeat(1) @(posedge clk);
    rst <= 1'b0;
    repeat(1) @(posedge clk);
endtask

task automatic run_pattern;
    @(negedge clk);
    EnableIn = 1;
    for (int i = 0 ; i < INPUT_SAMPLES ; i++) begin
        {InputI0,InputQ0,InputI1,InputQ1,InputI2,InputQ2,InputI3,InputQ3}
        ={test_pat[i*8+0],test_pat[i*8+1],test_pat[i*8+2],test_pat[i*8+3],test_pat[i*8+4],test_pat[i*8+5],test_pat[i*8+6],test_pat[i*8+7]};
        if(RANDOM_EnableIn) EnableIn = $random(seed);
        else begin
            EnableIn = 1;
        end
        while(~EnableIn)begin
            @(negedge clk);
            EnableIn=$random(seed);
        end
        @(negedge clk);
    end

    EnableIn = 1;
    {InputI0,InputQ0,InputI1,InputQ1,InputI2,InputQ2,InputI3,InputQ3}=0;
    repeat(1024)@(negedge clk);
    EnableIn = 0;


endtask

int read_data;
initial begin
    axil_bram_controller_inf.init_master();
    sync_reset;


    NMOD=3'd4; 
    BSMOD=2'd0;
    SEGMOD=1'd0;

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

    repeat(64)@(posedge clk);

    $finish;

end


integer Result_I1, Result_Q1;
integer Result_I2, Result_Q2;
integer Result_I3, Result_Q3;
integer Result_I4, Result_Q4;
integer Result_header;

integer i;    
            
initial begin
    Result_I1 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_I1.txt"));
    Result_I2 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_I2.txt"));
    Result_I3 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_I3.txt"));
    Result_I4 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_I4.txt"));
    Result_Q1 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_Q1.txt"));
    Result_Q2 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_Q2.txt"));
    Result_Q3 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_Q3.txt"));
    Result_Q4 = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_Q4.txt"));
    Result_header = $fopen($sformatf("%s%s",TB_DIR,"output/BAQ_output_header.txt"));
             
    for(i=0; i <100000; i= i +1) begin 
        if(fOutValid)  begin  
            $fdisplay(Result_I1,"%d ", BAQOutI0);
            $fdisplay(Result_I2,"%d ", BAQOutI1);
            $fdisplay(Result_I3,"%d ", BAQOutI2);
            $fdisplay(Result_I4,"%d ", BAQOutI3);
            $fdisplay(Result_Q1,"%d ", BAQOutQ0);
            $fdisplay(Result_Q2,"%d ", BAQOutQ1);
            $fdisplay(Result_Q3,"%d ", BAQOutQ2);
            $fdisplay(Result_Q4,"%d ", BAQOutQ3);
            if(fBlockEnd==1'b1) begin
                $fdisplay(Result_header,"%d ", {FVarianceAddress,fOverFlow});
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