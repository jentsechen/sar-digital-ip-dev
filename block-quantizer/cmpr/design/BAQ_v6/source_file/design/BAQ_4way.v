`timescale 1ns / 1ps
module BAQ_4way#(
    //-----------parameter-----------------------------
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
    
    parameter TM_BRAM_NUM = 32,
    localparam TM_DATA_CH = TM_BRAM_NUM*2,

    parameter ST_DATA_NUM = 512,
    parameter TM_DATA_NUM = 5*(127+1),

    localparam BRAM_DEPTH = ST_DATA_NUM+TM_DATA_NUM,

    // //AXIL parameter
    // parameter AXI_ADDR_W = $clog2(4*BRAM_DEPTH), //byte address
    // localparam AXI_DATA_W = 32

    //AXIL TO SP parameter
    localparam SP_ADDR_W = $clog2(BRAM_DEPTH),
    localparam SP_DATA_W = 32
) (
    /**********input ports**********/
    input clk,
    input rst,
    input bram_ctrl_rst,
    input [OUTPUTMOD_WORDLENGTH-1:0]NMOD,                    //output wordlength 
    input [BLOCKSIZEMOD_WRODLENGTH-1:0]BSMOD,                //blocksize 
    input [SEGMENTATIONMOD_WORDLENGTH-1:0]SEGMOD,            //segmentation
    input EnableIn,                                          
    input [ADC_WORDLENGTH-1:0]InputI0,                       //ADC data                       
    input [ADC_WORDLENGTH-1:0]InputI1,                       
    input [ADC_WORDLENGTH-1:0]InputI2,                       
    input [ADC_WORDLENGTH-1:0]InputI3,
    input [ADC_WORDLENGTH-1:0]InputQ0,                       
    input [ADC_WORDLENGTH-1:0]InputQ1,                       
    input [ADC_WORDLENGTH-1:0]InputQ2,                       
    input [ADC_WORDLENGTH-1:0]InputQ3,                
    input NUM_BLOCK,

    /**********output ports**********/
    output [VARIANCEADDRESS_WORDLENGTH-1:0]FVarianceAddress, //Variance
    output fOutValid,                                        //output valid
    output fOverFlow,                                        //variance is greater than upper boundary
    output fBlockEnd,
    output [OUTPUT_WORDLENGTH-1:0]BAQOutI0,                  //quantizer output
    output [OUTPUT_WORDLENGTH-1:0]BAQOutQ0,
    output [OUTPUT_WORDLENGTH-1:0]BAQOutI1,
    output [OUTPUT_WORDLENGTH-1:0]BAQOutQ1,
    output [OUTPUT_WORDLENGTH-1:0]BAQOutI2,
    output [OUTPUT_WORDLENGTH-1:0]BAQOutQ2,
    output [OUTPUT_WORDLENGTH-1:0]BAQOutI3,
    output [OUTPUT_WORDLENGTH-1:0]BAQOutQ3,  

    // /********AXIL IO*******/
    // input [AXI_ADDR_W-1:0] S_AXI_AWADDR,
    // input S_AXI_AWVALID,
    // output S_AXI_AWREADY,

    // input [AXI_DATA_W-1:0] S_AXI_WDATA,
    // input S_AXI_WVALID,
    // output S_AXI_WREADY,

    // output [1:0] S_AXI_BRESP,
    // output S_AXI_BVALID,
    // input S_AXI_BREADY,

    // input [AXI_ADDR_W-1:0] S_AXI_ARADDR,
    // input S_AXI_ARVALID,
    // output S_AXI_ARREADY,

    // output [AXI_DATA_W-1:0] S_AXI_RDATA,
    // output [1:0] S_AXI_RRESP,
    // output S_AXI_RVALID,
    // input S_AXI_RREADY

    /********AXIL TO SP IO*******/
    input sp_en,
    input sp_wen,
    input [SP_ADDR_W-1:0] sp_addr,  // 32-bits word address, instead of byte address
    input [SP_DATA_W-1:0] sp_wdata,
    output [SP_DATA_W-1:0] sp_rdata
);

localparam DB_PIPE = 4 + $clog2(2*(PARALLEL_NUMBER));//SQU(1)+ACC(1)+ADD(3) + SCAL(1) + SHIFTOUT(1)
localparam MAX_COMP_THRESHOLD = 15;
localparam ST_ADDR_W = SEGMENTATIONMOD_WORDLENGTH+SHIFT_WORDLENGTH;
localparam TM_ADDR_W = OUTPUTMOD_WORDLENGTH+THRESHOLD_NUMBER_W;


//-----------wire/reg------------------------------
wire locked;
wire Enable,EnableD1,EnableD2;

wire [ADC_WORDLENGTH-1:0]InputI_set[0:PARALLEL_NUMBER-1];
wire [ADC_WORDLENGTH-1:0]InputQ_set[0:PARALLEL_NUMBER-1];
wire [ADC_WORDLENGTH-1:0]InputID1_set[0:PARALLEL_NUMBER-1];
wire [ADC_WORDLENGTH-1:0]InputQD1_set[0:PARALLEL_NUMBER-1];
wire [ADC_WORDLENGTH-1:0]InputID2_set[0:PARALLEL_NUMBER-1];
wire [ADC_WORDLENGTH-1:0]InputQD2_set[0:PARALLEL_NUMBER-1];
wire [ADC_WORDLENGTH*PARALLEL_NUMBER-1:0]InputID2_seq;
wire [ADC_WORDLENGTH*PARALLEL_NUMBER-1:0]InputQD2_seq;

wire [ADC_WORDLENGTH*PARALLEL_NUMBER-1:0]RAMOutI_seq;
wire [ADC_WORDLENGTH*PARALLEL_NUMBER-1:0]RAMOutQ_seq;
wire [ADC_WORDLENGTH-1:0]RAMOutI_set[0:PARALLEL_NUMBER-1];
wire [ADC_WORDLENGTH-1:0]RAMOutQ_set[0:PARALLEL_NUMBER-1];
wire [ADC_WORDLENGTH-1:0]RAMOutID1_set[0:PARALLEL_NUMBER-1];
wire [ADC_WORDLENGTH-1:0]RAMOutQD1_set[0:PARALLEL_NUMBER-1];
wire [ADC_WORDLENGTH-1:0]RAMOutID2_set[0:PARALLEL_NUMBER-1];
wire [ADC_WORDLENGTH-1:0]RAMOutQD2_set[0:PARALLEL_NUMBER-1];
wire [ADC_WORDLENGTH-1:0]RAMOutID3_set[0:PARALLEL_NUMBER-1];
wire [ADC_WORDLENGTH-1:0]RAMOutQD3_set[0:PARALLEL_NUMBER-1];

wire [SQU_WORDLENGTH-1:0]SQUOutI_set[0:PARALLEL_NUMBER-1];
wire [SQU_WORDLENGTH-1:0]SQUOutQ_set[0:PARALLEL_NUMBER-1];
wire [SQU_WORDLENGTH-1:0]SQUOutID1_set[0:PARALLEL_NUMBER-1];
wire [SQU_WORDLENGTH-1:0]SQUOutQD1_set[0:PARALLEL_NUMBER-1];

wire [SQU_WORDLENGTH*PARALLEL_NUMBER-1:0]Acc_seq_I;
wire [SQU_WORDLENGTH*PARALLEL_NUMBER-1:0]Acc_seq_Q;

wire [PARALLEL_BLOCK_SIZE_WORDLENGTH-1:0]DB_counter;

wire[ACC_WORDLENGTH-1:0]ACCOut;
wire[ACC_WORDLENGTH-1:0]ACCOutD1;

reg[SHIFT_WORDLENGTH-1:0]ShifterOutD1;
wire[SHIFT_WORDLENGTH-1:0]ShifterOut;
// wire[SHIFT_WORDLENGTH-1:0]ShifterOutD1,ShifterOutD2,ShifterOutD3,
//                           ShifterOutD4,ShifterOutD5,ShifterOutD6,
//                           ShifterOutD7,ShifterOutD8,ShifterOutD9,
//                           ShifterOutD10,ShifterOutD11;

wire[SCALING_WORDLENGTH-1:0]ScalingValue;
reg[SCALING_WORDLENGTH-1:0]ScalingValueD1;

wire[MULTI_WORDLENGTH-1:0]MultiOutI_set[0:PARALLEL_NUMBER-1];
wire[MULTI_WORDLENGTH-1:0]MultiOutQ_set[0:PARALLEL_NUMBER-1];

wire[MULTI_WORDLENGTH-1:0]MultiOutID1_set[0:PARALLEL_NUMBER-1];
// wire[MULTI_WORDLENGTH-1:0]MultiOutID2_set[0:PARALLEL_NUMBER-1];
wire[MULTI_WORDLENGTH-1:0]ComMultiOutI_set[0:PARALLEL_NUMBER-1];
wire[MULTI_WORDLENGTH-1:0]ComMultiOutID1_set[0:PARALLEL_NUMBER-1];

wire[MULTI_WORDLENGTH-1:0]MultiOutQD1_set[0:PARALLEL_NUMBER-1];
// wire[MULTI_WORDLENGTH-1:0]MultiOutQD2_set[0:PARALLEL_NUMBER-1];
wire[MULTI_WORDLENGTH-1:0]ComMultiOutQ_set[0:PARALLEL_NUMBER-1];
wire[MULTI_WORDLENGTH-1:0]ComMultiOutQD1_set[0:PARALLEL_NUMBER-1];

/*************************************************/
/*         Threshold memory                      */
/*************************************************/
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdI_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdI1_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdI2_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdI3_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdI4_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdI5_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdI6_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdI7_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdI8_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdI9_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdI10_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdI11_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdI12_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdI13_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdI14_set[0:PARALLEL_NUMBER-1];

wire [THRESHOLD_WORDLENGTH-1:0]ThresholdQ_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdQ1_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdQ2_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdQ3_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdQ4_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdQ5_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdQ6_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdQ7_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdQ8_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdQ9_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdQ10_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdQ11_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdQ12_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdQ13_set[0:PARALLEL_NUMBER-1];
wire [THRESHOLD_WORDLENGTH-1:0]ThresholdQ14_set[0:PARALLEL_NUMBER-1];
/*************************************************/

wire [MAX_COMP_THRESHOLD-1:0]CompOutputI_set[0:PARALLEL_NUMBER-1];
wire [MAX_COMP_THRESHOLD-1:0]CompOutputQ_set[0:PARALLEL_NUMBER-1];

wire [MAX_COMP_THRESHOLD-1:0]CompOutputID1_set[0:PARALLEL_NUMBER-1];
wire [MAX_COMP_THRESHOLD-1:0]CompOutputQD1_set[0:PARALLEL_NUMBER-1];

wire [OUTPUT_WORDLENGTH-1:0]pre_BAQOutI_set[0:PARALLEL_NUMBER-1];
wire [OUTPUT_WORDLENGTH-1:0]pre_BAQOutQ_set[0:PARALLEL_NUMBER-1];

wire [OUTPUT_WORDLENGTH-1:0]BAQOutI_set[0:PARALLEL_NUMBER-1];
wire [OUTPUT_WORDLENGTH-1:0]BAQOutQ_set[0:PARALLEL_NUMBER-1];

wire [OUTPUT_WORDLENGTH-1:0]pre_BAQOutI0;
wire [OUTPUT_WORDLENGTH-1:0]pre_BAQOutI1;
wire [OUTPUT_WORDLENGTH-1:0]pre_BAQOutI2;
wire [OUTPUT_WORDLENGTH-1:0]pre_BAQOutI3;
wire [OUTPUT_WORDLENGTH-1:0]pre_BAQOutQ0;
wire [OUTPUT_WORDLENGTH-1:0]pre_BAQOutQ1;
wire [OUTPUT_WORDLENGTH-1:0]pre_BAQOutQ2;
wire [OUTPUT_WORDLENGTH-1:0]pre_BAQOutQ3;

wire [ST_ADDR_W-1:0] st_bram_addr;//{SEGMOD,Address}
wire [SCALING_WORDLENGTH-1:0] st_bram_dout;//DataOut
wire [TM_DATA_CH*TM_ADDR_W-1:0]tm_bram_addr;//{NMODE,Address}
wire [TM_DATA_CH*THRESHOLD_WORDLENGTH-1:0]tm_bram_dout;

genvar gen_i;
//-----------function/Initial------------------------------
assign InputI_set[0] = InputI0;
assign InputI_set[1] = InputI1;
assign InputI_set[2] = InputI2;
assign InputI_set[3] = InputI3;

assign InputQ_set[0] = InputQ0;
assign InputQ_set[1] = InputQ1;
assign InputQ_set[2] = InputQ2;
assign InputQ_set[3] = InputQ3;

assign BAQOutI0 = BAQOutI_set[0];
assign BAQOutI1 = BAQOutI_set[1];
assign BAQOutI2 = BAQOutI_set[2];
assign BAQOutI3 = BAQOutI_set[3];

assign BAQOutQ0 = BAQOutQ_set[0];
assign BAQOutQ1 = BAQOutQ_set[1];
assign BAQOutQ2 = BAQOutQ_set[2];
assign BAQOutQ3 = BAQOutQ_set[3];   
//-----------pipeline----------------------------------------------------------------
/************input pipeline************************/
NESingleFF #(.SFF_Wordlength(1))ED1  (.rst(rst),.DInput(EnableIn),.QOutput(EnableD1),.clk(clk));
NESingleFF #(.SFF_Wordlength(1))ED2  (.rst(rst),.DInput(EnableD1),.QOutput(Enable),.clk(clk));
generate 
    for(gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1)begin
        NESingleFF #(.SFF_Wordlength(ADC_WORDLENGTH))ID1(.rst(rst),.DInput(InputI_set[gen_i]),.QOutput(InputID1_set[gen_i]),.clk(clk));
        NESingleFF #(.SFF_Wordlength(ADC_WORDLENGTH))QD1(.rst(rst),.DInput(InputQ_set[gen_i]),.QOutput(InputQD1_set[gen_i]),.clk(clk));

        NESingleFF #(.SFF_Wordlength(ADC_WORDLENGTH))ID2(.rst(rst),.DInput(InputID1_set[gen_i]),.QOutput(InputID2_set[gen_i]),.clk(clk));
        NESingleFF #(.SFF_Wordlength(ADC_WORDLENGTH))QD2(.rst(rst),.DInput(InputQD1_set[gen_i]),.QOutput(InputQD2_set[gen_i]),.clk(clk));
    end
endgenerate
/************Delay buffer pipeline*****************/
for(gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1)begin
    RAMpipeFF  #(.SFF_Wordlength(ADC_WORDLENGTH),.PIPE_NUM(DB_PIPE))DBIDN(.Enable(Enable),.rst(rst),.DIN(RAMOutI_set[gen_i]),.DOUT(RAMOutID3_set[gen_i]),.clk(clk));
    RAMpipeFF  #(.SFF_Wordlength(ADC_WORDLENGTH),.PIPE_NUM(DB_PIPE))DBQDN(.Enable(Enable),.rst(rst),.DIN(RAMOutQ_set[gen_i]),.DOUT(RAMOutQD3_set[gen_i]),.clk(clk));
end
/************Squarer pipeline**********************/
generate
for(gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1)begin: squ_pipe_block
    SingleFF #(.SFF_Wordlength(SQU_WORDLENGTH))SQUID1(.Enable(Enable),.rst(rst),.DInput(SQUOutI_set[gen_i]),.QOutput(SQUOutID1_set[gen_i]),.clk(clk));
    SingleFF #(.SFF_Wordlength(SQU_WORDLENGTH))SQUQD1(.Enable(Enable),.rst(rst),.DInput(SQUOutQ_set[gen_i]),.QOutput(SQUOutQD1_set[gen_i]),.clk(clk));
end
endgenerate
/************Accumulator pipeline******************/
SingleFF #(.SFF_Wordlength(ACC_WORDLENGTH))ACCD1(.Enable(Enable),.rst(rst),.DInput(ACCOut),.QOutput(ACCOutD1),.clk(clk));
/************Multiplier pipeline*******************/
generate
    for(gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1)begin: multi_pipe_block
        SingleFF #(.SFF_Wordlength(MULTI_WORDLENGTH))MULTIID1(.Enable(Enable),.rst(rst),.DInput(MultiOutI_set[gen_i]),.QOutput(MultiOutID1_set[gen_i]),.clk(clk));
        SingleFF #(.SFF_Wordlength(MULTI_WORDLENGTH))MULTIQD1(.Enable(Enable),.rst(rst),.DInput(MultiOutQ_set[gen_i]),.QOutput(MultiOutQD1_set[gen_i]),.clk(clk));
        // SingleFF #(.SFF_Wordlength(MULTI_WORDLENGTH))MULTIID2(.Enable(Enable),.rst(rst),.DInput(MultiOutID1_set[gen_i]),.QOutput(MultiOutID2_set[gen_i]),.clk(clk));
        // SingleFF #(.SFF_Wordlength(MULTI_WORDLENGTH))MULTIQD2(.Enable(Enable),.rst(rst),.DInput(MultiOutQD1_set[gen_i]),.QOutput(MultiOutQD2_set[gen_i]),.clk(clk));
        SingleFF #(.SFF_Wordlength(MULTI_WORDLENGTH))COMMULTIID1(.Enable(Enable),.rst(rst),.DInput(ComMultiOutI_set[gen_i]),.QOutput(ComMultiOutID1_set[gen_i]),.clk(clk));
        SingleFF #(.SFF_Wordlength(MULTI_WORDLENGTH))COMMULTIQD1(.Enable(Enable),.rst(rst),.DInput(ComMultiOutQ_set[gen_i]),.QOutput(ComMultiOutQD1_set[gen_i]),.clk(clk));
    end
endgenerate
/************Comparator pipeline*******************/
generate
    for(gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1)begin: comp_pipe_block
        SingleFF #(.SFF_Wordlength(MAX_COMP_THRESHOLD))CompsignID1(.Enable(Enable),.rst(rst),.DInput(CompOutputI_set[gen_i]),.QOutput(CompOutputID1_set[gen_i]),.clk(clk));
        SingleFF #(.SFF_Wordlength(MAX_COMP_THRESHOLD))CompsignQD1(.Enable(Enable),.rst(rst),.DInput(CompOutputQ_set[gen_i]),.QOutput(CompOutputQD1_set[gen_i]),.clk(clk));
    end
endgenerate
/************ShifterOut pipeline***********************/
// SingleFF #(.SFF_Wordlength(VARIANCEADDRESS_WORDLENGTH))SHIFTEROUTD1(.Enable(Enable),.rst(rst),.DInput(ShifterOut),.QOutput(ShifterOutD1),.clk(clk));
// SingleFF #(.SFF_Wordlength(VARIANCEADDRESS_WORDLENGTH))SHIFTEROUTD2(.Enable(Enable),.rst(rst),.DInput(ShifterOutD1),.QOutput(ShifterOutD2),.clk(clk));
// SingleFF #(.SFF_Wordlength(VARIANCEADDRESS_WORDLENGTH))SHIFTEROUTD3(.Enable(Enable),.rst(rst),.DInput(ShifterOutD2),.QOutput(ShifterOutD3),.clk(clk));
// SingleFF #(.SFF_Wordlength(VARIANCEADDRESS_WORDLENGTH))SHIFTEROUTD4(.Enable(Enable),.rst(rst),.DInput(ShifterOutD3),.QOutput(ShifterOutD4),.clk(clk));
// SingleFF #(.SFF_Wordlength(VARIANCEADDRESS_WORDLENGTH))SHIFTEROUTD5(.Enable(Enable),.rst(rst),.DInput(ShifterOutD4),.QOutput(ShifterOutD5),.clk(clk));
// SingleFF #(.SFF_Wordlength(VARIANCEADDRESS_WORDLENGTH))SHIFTEROUTD6(.Enable(Enable),.rst(rst),.DInput(ShifterOutD5),.QOutput(ShifterOutD6),.clk(clk));
// SingleFF #(.SFF_Wordlength(VARIANCEADDRESS_WORDLENGTH))SHIFTEROUTD7(.Enable(Enable),.rst(rst),.DInput(ShifterOutD6),.QOutput(ShifterOutD7),.clk(clk));
// SingleFF #(.SFF_Wordlength(VARIANCEADDRESS_WORDLENGTH))SHIFTEROUTD8(.Enable(Enable),.rst(rst),.DInput(ShifterOutD7),.QOutput(ShifterOutD8),.clk(clk));
// SingleFF #(.SFF_Wordlength(VARIANCEADDRESS_WORDLENGTH))SHIFTEROUTD9(.Enable(Enable),.rst(rst),.DInput(ShifterOutD8),.QOutput(ShifterOutD9),.clk(clk));
// SingleFF #(.SFF_Wordlength(VARIANCEADDRESS_WORDLENGTH))SHIFTEROUTD10(.Enable(Enable),.rst(rst),.DInput(ShifterOutD9),.QOutput(ShifterOutD10),.clk(clk));
// SingleFF #(.SFF_Wordlength(VARIANCEADDRESS_WORDLENGTH))SHIFTEROUTD11(.Enable(Enable),.rst(rst),.DInput(ShifterOutD10),.QOutput(FVarianceAddress),.clk(clk));
/************ShifterOut pipeline (SRL optimized)***********************/
// 第 1 級：FF（ShifterOutD1 被第 360 行 scaling value 邏輯使用）
always @(posedge clk or posedge rst) begin
    if (rst)
        ShifterOutD1 <= 0;
    else if (Enable)
        ShifterOutD1 <= ShifterOut;
end

// 第 2~10 級：SRL（9 級延遲）
(* shreg_extract = "yes", srl_style = "srl_reg" *)
reg [VARIANCEADDRESS_WORDLENGTH-1:0] shifter_srl [0:8];

integer shifter_i;
always @(posedge clk) begin
    if (Enable) begin
        shifter_srl[0] <= ShifterOutD1;
        for (shifter_i = 1; shifter_i < 9; shifter_i = shifter_i + 1)
            shifter_srl[shifter_i] <= shifter_srl[shifter_i-1];
    end
end

// 第 11 級：FF（支援 reset，輸出到 FVarianceAddress）
reg [VARIANCEADDRESS_WORDLENGTH-1:0] FVarianceAddress_reg;
always @(posedge clk or posedge rst) begin
    if (rst)
        FVarianceAddress_reg <= 0;
    else if (Enable)
        FVarianceAddress_reg <= shifter_srl[8];
end

assign FVarianceAddress = FVarianceAddress_reg;
/************Output pipeline***********************/
generate
    for(gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1)begin: output_pipe_block
        SingleFF #(.SFF_Wordlength(OUTPUT_WORDLENGTH))BAQOUTI(.Enable(Enable),.rst(rst),.DInput(pre_BAQOutI_set[gen_i]),.QOutput(BAQOutI_set[gen_i]),.clk(clk));
        SingleFF #(.SFF_Wordlength(OUTPUT_WORDLENGTH))BAQOUTQ(.Enable(Enable),.rst(rst),.DInput(pre_BAQOutQ_set[gen_i]),.QOutput(BAQOutQ_set[gen_i]),.clk(clk));
    end
endgenerate

//-----------function-------------------------------------------------------------------------------//
/************Delay Buffer**************************/
generate
    for(gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1)begin
        assign InputID2_seq[ADC_WORDLENGTH*gen_i +: ADC_WORDLENGTH] = InputID2_set[gen_i];
        assign InputQD2_seq[ADC_WORDLENGTH*gen_i +: ADC_WORDLENGTH] = InputQD2_set[gen_i];
        assign RAMOutI_set[gen_i] = RAMOutI_seq[ADC_WORDLENGTH*gen_i +: ADC_WORDLENGTH];
        assign RAMOutQ_set[gen_i] = RAMOutQ_seq[ADC_WORDLENGTH*gen_i +: ADC_WORDLENGTH];
    end
endgenerate
Delay_Buffer #(.ADC_WORDLENGTH(ADC_WORDLENGTH),.BLOCKSIZEMOD_WRODLENGTH(BLOCKSIZEMOD_WRODLENGTH),.PARALLEL_BLOCK_SIZE_WORDLENGTH(PARALLEL_BLOCK_SIZE_WORDLENGTH),.PARALLEL_NUMBER(PARALLEL_NUMBER))
    DB0(.clk(clk),.rst(rst),
        .enable(Enable),
        .BSMOD(BSMOD),
        .DataInI_seq(InputID2_seq),.DataInQ_seq(InputQD2_seq),
        .counter(DB_counter),.fOutValid(fOutValid),.fBlockEnd(fBlockEnd),
        .DataOutI_seq(RAMOutI_seq),.DataOutQ_seq(RAMOutQ_seq));
/***********Squarer*******************************/
generate
    for (gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1) begin
        Squarer #(.ADC_WORDLENGTH(ADC_WORDLENGTH),.SQU_WORDLENGTH(SQU_WORDLENGTH),.ADC_FRAC_WORDLENGTH(ADC_FRAC_WORDLENGTH),.SQU_FRAC_WORDLENGTH(SQU_FRAC_WORDLENGTH))
            SQU0 (.inI(InputID2_set[gen_i]),.inQ(InputQD2_set[gen_i]),.outI(SQUOutI_set[gen_i]),.outQ(SQUOutQ_set[gen_i]));
    end
endgenerate
/***********Accumulator***************************/
generate
    for (gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1) begin
        assign Acc_seq_I[SQU_WORDLENGTH*gen_i +: SQU_WORDLENGTH] = SQUOutID1_set[gen_i];
        assign Acc_seq_Q[SQU_WORDLENGTH*gen_i +: SQU_WORDLENGTH] = SQUOutQD1_set[gen_i];
    end
endgenerate
Accumulator #(.SQU_WORDLENGTH(SQU_WORDLENGTH),.PARALLEL_BLOCK_SIZE_WORDLENGTH(PARALLEL_BLOCK_SIZE_WORDLENGTH),.ACC_WORDLENGTH(ACC_WORDLENGTH),.PARALLEL_NUMBER(PARALLEL_NUMBER))
    Acc0(.clk(clk),.rst(rst),.DB_BUF_counter(DB_counter),.Enable(Enable),.In_seq_I(Acc_seq_I),.In_seq_Q(Acc_seq_Q),.Out_sum(ACCOut));
/***********Shifter*******************************/
Shifter #(.BLOCKSIZEMOD_WRODLENGTH (BLOCKSIZEMOD_WRODLENGTH),.SEGMENTATIONMOD_WORDLENGTH(SEGMENTATIONMOD_WORDLENGTH),
    .VARIANCEADDRESS_WORDLENGTH(VARIANCEADDRESS_WORDLENGTH),.PARALLEL_BLOCK_SIZE_WORDLENGTH(PARALLEL_BLOCK_SIZE_WORDLENGTH),
    .SCALING_WORDLENGTH(SCALING_WORDLENGTH),.ACC_WORDLENGTH(ACC_WORDLENGTH),.PARALLEL_NUMBER(PARALLEL_NUMBER))
    Shi0(.clk(clk),.rst(rst),.SEGMOD(SEGMOD),.BSMOD(BSMOD),.Enable(Enable),.ShifterIn(ACCOutD1),.counter(DB_counter),.ShifterOut(ShifterOut),.fOverFlow(fOverFlow),.fBlockEnd(fBlockEnd));
/***********scaling value*************************/
assign st_bram_addr = (SEGMOD == 1'b0)?{SEGMOD, 1'b0, ShifterOut[0+:SHIFT_WORDLENGTH-1]}:{SEGMOD, ShifterOut};
always @( *) begin
    if(SEGMOD == 1'b0)begin
        if(ShifterOutD1[7] == 1'b1)begin
            ScalingValueD1 = {st_bram_dout[13:0],3'b0};
        end else begin
            ScalingValueD1 = {{2{1'b0}},st_bram_dout};
        end
    end else begin
        ScalingValueD1 = {{2{1'b0}},st_bram_dout};
    end
end
/***********BRAM controller*************************/
BRAM_controller #(
    .SHIFT_WORDLENGTH(SHIFT_WORDLENGTH),
    .SCALING_NUMBER(SCALING_NUMBER),
    .SCALING_WORDLENGTH(SCALING_WORDLENGTH),
    .OUTPUTMOD_WORDLENGTH(OUTPUTMOD_WORDLENGTH),
    .THRESHOLD_NUMBER_W(THRESHOLD_NUMBER_W),
    .THRESHOLD_WORDLENGTH(THRESHOLD_WORDLENGTH),
    
    .TM_BRAM_NUM(TM_BRAM_NUM),
    .ST_DATA_NUM(ST_DATA_NUM),
    .TM_DATA_NUM(TM_DATA_NUM)
    // .AXI_ADDR_W(AXI_ADDR_W)
)u_BRAM_controller(
  .clk           (clk           ),
  .rst           (bram_ctrl_rst ),
  .Enable        (Enable        ),
//   .S_AXI_AWADDR  (S_AXI_AWADDR  ),
//   .S_AXI_AWVALID (S_AXI_AWVALID ),
//   .S_AXI_AWREADY (S_AXI_AWREADY ),
//   .S_AXI_WDATA   (S_AXI_WDATA   ),
//   .S_AXI_WVALID  (S_AXI_WVALID  ),
//   .S_AXI_WREADY  (S_AXI_WREADY  ),
//   .S_AXI_BRESP   (S_AXI_BRESP   ),
//   .S_AXI_BVALID  (S_AXI_BVALID  ),
//   .S_AXI_BREADY  (S_AXI_BREADY  ),
//   .S_AXI_ARADDR  (S_AXI_ARADDR  ),
//   .S_AXI_ARVALID (S_AXI_ARVALID ),
//   .S_AXI_ARREADY (S_AXI_ARREADY ),
//   .S_AXI_RDATA   (S_AXI_RDATA   ),
//   .S_AXI_RRESP   (S_AXI_RRESP   ),
//   .S_AXI_RVALID  (S_AXI_RVALID  ),
//   .S_AXI_RREADY  (S_AXI_RREADY  ),
  .sp_en         (sp_en     ),
  .sp_wen        (sp_wen    ),
  .sp_addr       (sp_addr   ),
  .sp_wdata      (sp_wdata  ),
  .sp_rdata      (sp_rdata  ),
  .st_bram_addr  (st_bram_addr  ),
  .st_bram_dout  (st_bram_dout  ),
  .tm_bram_addr  (tm_bram_addr  ),
  .tm_bram_dout  (tm_bram_dout  )
);

/************Multiplier****************************/
generate
    for(gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1)begin: multi_block
        Multiplier #(.ADC_WORDLENGTH(ADC_WORDLENGTH),.ADC_FRAC_WORDLENGTH(ADC_FRAC_WORDLENGTH),.SCALING_WORDLENGTH(SCALING_WORDLENGTH),.SCALING_FRAC_WORDLENGTH(SCALING_FRAC_WORDLENGTH),.MULTI_WORDLENGTH(MULTI_WORDLENGTH),.MULTI_FRAC_WORDLENGTH(MULTI_FRAC_WORDLENGTH))
            MUL0(.Multiplicand(ScalingValueD1),.MultiInI(RAMOutID3_set[gen_i]),.MultiInQ(RAMOutQD3_set[gen_i]),.MultiOutI(MultiOutI_set[gen_i]),.MultiOutQ(MultiOutQ_set[gen_i]));
    end
endgenerate
/************2'S Componement***********************/
generate
    for(gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1)begin : multi_2sCom_block
        ComMulti #(.MULTI_WORDLENGTH(MULTI_WORDLENGTH))
            ComMultiSet(.MultiInI(MultiOutID1_set[gen_i]),.MultiInQ(MultiOutQD1_set[gen_i]),.ComMultiOutI(ComMultiOutI_set[gen_i]),.ComMultiOutQ(ComMultiOutQ_set[gen_i]));
    end
endgenerate
/************OUTPUT**********************/
generate
    for(gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1)begin : out_block
        compare_cell_wrap u_compare_cell_wrap(
            .clk           (clk           ),
            .rst             (rst             ),
            .Enable          (Enable          ),
            .NMOD            (NMOD            ),
            .MultiI          (MultiOutID1_set[gen_i]),
            .MultiQ          (MultiOutQD1_set[gen_i]),
            .ComMultiI       (ComMultiOutI_set[gen_i]),
            .ComMultiQ       (ComMultiOutQ_set[gen_i]),

            .bram_data_0     (tm_bram_dout[(0+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_0  (tm_bram_addr[(0+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),
            .bram_data_1     (tm_bram_dout[(1+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_1  (tm_bram_addr[(1+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),
            .bram_data_2     (tm_bram_dout[(2+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_2  (tm_bram_addr[(2+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),
            .bram_data_3     (tm_bram_dout[(3+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_3  (tm_bram_addr[(3+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),
            .bram_data_4     (tm_bram_dout[(4+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_4  (tm_bram_addr[(4+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),
            .bram_data_5     (tm_bram_dout[(5+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_5  (tm_bram_addr[(5+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),
            .bram_data_6     (tm_bram_dout[(6+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_6  (tm_bram_addr[(6+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),
            .bram_data_7     (tm_bram_dout[(7+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_7  (tm_bram_addr[(7+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),
            .bram_data_8     (tm_bram_dout[(8+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_8  (tm_bram_addr[(8+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),
            .bram_data_9     (tm_bram_dout[(9+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_9  (tm_bram_addr[(9+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),
            .bram_data_10    (tm_bram_dout[(10+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_10 (tm_bram_addr[(10+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),
            .bram_data_11    (tm_bram_dout[(11+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_11 (tm_bram_addr[(11+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),
            .bram_data_12    (tm_bram_dout[(12+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_12 (tm_bram_addr[(12+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),
            .bram_data_13    (tm_bram_dout[(13+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_13 (tm_bram_addr[(13+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),
            .bram_data_14    (tm_bram_dout[(14+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_14 (tm_bram_addr[(14+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),
            .bram_data_15    (tm_bram_dout[(15+gen_i*16)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]),
            .bram_address_15 (tm_bram_addr[(15+gen_i*16)*TM_ADDR_W+:TM_ADDR_W]),

            .CompOutI        (pre_BAQOutI_set[gen_i]),
            .CompOutQ        (pre_BAQOutQ_set[gen_i])
        );  
    end
endgenerate
endmodule
