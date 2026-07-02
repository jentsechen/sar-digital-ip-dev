module compare_cell_wrap #(
//-----------parameters---------------------------
parameter MULTI_WORDLENGTH = 14,
parameter THRESHOLD_WORDLENGTH = 14,
parameter COMP_NUMBER_WORDLENGTH = 7,
parameter OUTPUT_WORDLENGTH = 8,
parameter INDEX_WORDLENGTH = 7,
parameter OUTPUTMOD_WORDLENGTH = 3,
parameter BRAM_DATA_WORDLENGTH = 14,
parameter BRAM_ADDR_WORDLENGTH = 10
) (
//-----------input/output---------------------------
    input clk,
    input rst,
    input Enable,
    input [OUTPUTMOD_WORDLENGTH-1:0]NMOD,
    input signed [MULTI_WORDLENGTH-1:0]MultiI,
    input signed [MULTI_WORDLENGTH-1:0]MultiQ,
    input signed [MULTI_WORDLENGTH-1:0]ComMultiI,
    input signed [MULTI_WORDLENGTH-1:0]ComMultiQ,
    //BRAM port0
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_0,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_0,
    //BRAM port1
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_1,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_1,
    //BRAM port2
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_2,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_2,
    //BRAM port3
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_3,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_3,
    //BRAM port4
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_4,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_4,
    //BRAM port5
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_5,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_5,
    //BRAM port6
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_6,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_6,
    //BRAM port7
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_7,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_7,
     //BRAM port8
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_8,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_8,
    //BRAM port9
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_9,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_9,
    //BRAM port10
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_10,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_10,
    //BRAM port11
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_11,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_11,
    //BRAM port12
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_12,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_12,
    //BRAM port13
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_13,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_13,
    //BRAM port14
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_14,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_14,
    //BRAM port15
    input [BRAM_DATA_WORDLENGTH-1:0] bram_data_15,
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_address_15,

    output [OUTPUT_WORDLENGTH-1:0]CompOutI,
    output [OUTPUT_WORDLENGTH-1:0]CompOutQ
);
localparam COMP_STAGE = 9;//8+1(init stage)
localparam BRAM_PORT_NUM = 16;
//-----------wire/reg------------------------------
genvar gen_i;
integer i;
wire [INDEX_WORDLENGTH-1:0]bram_addr_stage[0:BRAM_PORT_NUM-1];
wire [THRESHOLD_WORDLENGTH-1:0]bram_data_stage[0:BRAM_PORT_NUM-1];
//-----------function-----------------------------
assign bram_data_stage[0] = bram_data_0[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[1] = bram_data_1[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[2] = bram_data_2[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[3] = bram_data_3[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[4] = bram_data_4[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[5] = bram_data_5[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[6] = bram_data_6[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[7] = bram_data_7[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[8] = bram_data_8[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[9] = bram_data_9[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[10] = bram_data_10[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[11] = bram_data_11[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[12] = bram_data_12[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[13] = bram_data_13[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[14] = bram_data_14[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[15] = bram_data_15[0 +: THRESHOLD_WORDLENGTH];

assign bram_address_0[0 +: (OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[0]};
assign bram_address_1[0 +: (OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[1]};
assign bram_address_2[0 +: (OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[2]};
assign bram_address_3[0 +: (OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[3]};
assign bram_address_4[0 +: (OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[4]};
assign bram_address_5[0 +: (OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[5]};
assign bram_address_6[0 +: (OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[6]};
assign bram_address_7[0 +: (OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[7]};
assign bram_address_8[0 +: (OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[8]};
assign bram_address_9[0 +: (OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[9]};
assign bram_address_10[0 +:(OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[10]};
assign bram_address_11[0 +:(OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[11]};
assign bram_address_12[0 +:(OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[12]};
assign bram_address_13[0 +:(OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[13]};
assign bram_address_14[0 +:(OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[14]};
assign bram_address_15[0 +:(OUTPUTMOD_WORDLENGTH+INDEX_WORDLENGTH)] = {NMOD,bram_addr_stage[15]};

compare_cell_IQ#(
		.MULTI_WORDLENGTH(MULTI_WORDLENGTH)
		,.THRESHOLD_WORDLENGTH(THRESHOLD_WORDLENGTH)
		,.COMP_NUMBER_WORDLENGTH(COMP_NUMBER_WORDLENGTH)
		,.OUTPUT_WORDLENGTH(OUTPUT_WORDLENGTH)
        ,. OUTPUTMOD_WORDLENGTH(OUTPUTMOD_WORDLENGTH)
		,.INDEX_WORDLENGTH(INDEX_WORDLENGTH)
        ,.BRAM_DATA_WORDLENGTH(BRAM_DATA_WORDLENGTH)
        ,.BRAM_ADDR_WORDLENGTH(BRAM_ADDR_WORDLENGTH)
)comp_out_I(
        .clk(clk)
       ,.rst(rst)
       ,.Enable(Enable)
       ,.NMOD(NMOD)
       ,.MultiIn(MultiI)
       ,.ComMultiIn(ComMultiI)
       ,.CompOut(CompOutI)
       //BRAM port0
       ,.bram_data_0(bram_data_stage[0])
       ,.bram_address_0(bram_addr_stage[0])
       //BRAM port1
       ,.bram_data_1(bram_data_stage[1])
       ,.bram_address_1(bram_addr_stage[1])
       //BRAM port2
       ,.bram_data_2(bram_data_stage[2])
       ,.bram_address_2(bram_addr_stage[2])
       //BRAM port3
       ,.bram_data_3(bram_data_stage[3])
       ,.bram_address_3(bram_addr_stage[3])
       //BRAM port4
       ,.bram_data_4(bram_data_stage[4])
       ,.bram_address_4(bram_addr_stage[4])
       //BRAM port5
       ,.bram_data_5(bram_data_stage[5])
       ,.bram_address_5(bram_addr_stage[5])
       //BRAM port6
       ,.bram_data_6(bram_data_stage[6])
       ,.bram_address_6(bram_addr_stage[6])
       //BRAM port7
       ,.bram_data_7(bram_data_stage[7])
       ,.bram_address_7(bram_addr_stage[7])
);
compare_cell_IQ#(
		.MULTI_WORDLENGTH(MULTI_WORDLENGTH)
		,.THRESHOLD_WORDLENGTH(THRESHOLD_WORDLENGTH)
		,.COMP_NUMBER_WORDLENGTH(COMP_NUMBER_WORDLENGTH)
		,.OUTPUT_WORDLENGTH(OUTPUT_WORDLENGTH)
        ,. OUTPUTMOD_WORDLENGTH(OUTPUTMOD_WORDLENGTH)
		,.INDEX_WORDLENGTH(INDEX_WORDLENGTH)
        ,.BRAM_DATA_WORDLENGTH(BRAM_DATA_WORDLENGTH)
        ,.BRAM_ADDR_WORDLENGTH(BRAM_ADDR_WORDLENGTH)
)comp_out_Q(
        .clk(clk)
       ,.rst(rst)
       ,.Enable(Enable)
       ,.NMOD(NMOD)
       ,.MultiIn(MultiQ)
       ,.ComMultiIn(ComMultiQ)
       ,.CompOut(CompOutQ)
       //BRAM port0
       ,.bram_data_0(bram_data_stage[8])
       ,.bram_address_0(bram_addr_stage[8])
       //BRAM port1
       ,.bram_data_1(bram_data_stage[9])
       ,.bram_address_1(bram_addr_stage[9])
       //BRAM port2
       ,.bram_data_2(bram_data_stage[10])
       ,.bram_address_2(bram_addr_stage[10])
       //BRAM port3
       ,.bram_data_3(bram_data_stage[11])
       ,.bram_address_3(bram_addr_stage[11])
       //BRAM port4
       ,.bram_data_4(bram_data_stage[12])
       ,.bram_address_4(bram_addr_stage[12])
       //BRAM port5
       ,.bram_data_5(bram_data_stage[13])
       ,.bram_address_5(bram_addr_stage[13])
       //BRAM port6
       ,.bram_data_6(bram_data_stage[14])
       ,.bram_address_6(bram_addr_stage[14])
       //BRAM port7
       ,.bram_data_7(bram_data_stage[15])
       ,.bram_address_7(bram_addr_stage[15])
);

endmodule