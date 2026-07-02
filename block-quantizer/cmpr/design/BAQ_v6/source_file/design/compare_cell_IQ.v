module compare_cell_IQ #(
//-----------parameters---------------------------
parameter MULTI_WORDLENGTH = 14,
parameter THRESHOLD_WORDLENGTH = 14,
parameter COMP_NUMBER_WORDLENGTH = 7,
parameter OUTPUT_WORDLENGTH = 8,
parameter INDEX_WORDLENGTH = 7,
parameter OUTPUTMOD_WORDLENGTH = 3,
parameter BRAM_DATA_WORDLENGTH = 16,
parameter BRAM_ADDR_WORDLENGTH = 16
) (
//-----------input/output---------------------------
    input clk,
    input rst,
    input Enable,
    input [OUTPUTMOD_WORDLENGTH-1:0]NMOD,
    input signed [MULTI_WORDLENGTH-1:0]MultiIn,
    input signed [MULTI_WORDLENGTH-1:0]ComMultiIn,
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

    output reg[OUTPUT_WORDLENGTH-1:0]CompOut
);
localparam COMP_STAGE = 9;//8+1(init stage)
//-----------wire/reg------------------------------
genvar gen_i;
integer i;
reg [COMP_NUMBER_WORDLENGTH-1:0]init_threshold_index;
wire [OUTPUT_WORDLENGTH-1:0]compress_data_in_stage[0:COMP_STAGE-1];
wire [OUTPUT_WORDLENGTH-1:0]pre_CompOut;
wire comp_in_sign_stage[0:COMP_STAGE-1];
wire [MULTI_WORDLENGTH-1:0]comp_in_stage[0:COMP_STAGE-1];
wire [INDEX_WORDLENGTH-1:0]threshold_index_stage[0:COMP_STAGE-1];
wire [COMP_NUMBER_WORDLENGTH-1:0]comp_number_in_stage[0:COMP_STAGE-1];
wire [INDEX_WORDLENGTH-1:0]bram_addr_stage[0:COMP_STAGE-1];
wire [THRESHOLD_WORDLENGTH-1:0]bram_data_stage[0:COMP_STAGE-1];
//-----------function-----------------------------
always @(*) begin
    case(NMOD)
        0:init_threshold_index = 7'd1;  //2
		1:init_threshold_index = 7'd2;  //3
		2:init_threshold_index = 7'd4;  //4
		3:init_threshold_index = 7'd16; //6
		4:init_threshold_index = 7'd64; //8
		default:init_threshold_index = 7'd64;
    endcase
end
assign compress_data_in_stage[0] = 0;
assign comp_in_sign_stage[0] = MultiIn[MULTI_WORDLENGTH-1];
assign comp_in_stage[0] = (comp_in_sign_stage[0])?ComMultiIn:MultiIn;// 1:negtive 0:postive
assign threshold_index_stage[0] = init_threshold_index-1;
assign comp_number_in_stage[0] = init_threshold_index;

assign bram_data_stage[0] = bram_data_0[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[1] = bram_data_1[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[2] = bram_data_2[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[3] = bram_data_3[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[4] = bram_data_4[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[5] = bram_data_5[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[6] = bram_data_6[0 +: THRESHOLD_WORDLENGTH];
assign bram_data_stage[7] = bram_data_7[0 +: THRESHOLD_WORDLENGTH];

assign bram_address_0[0 +: INDEX_WORDLENGTH] = bram_addr_stage[0];
assign bram_address_1[0 +: INDEX_WORDLENGTH] = bram_addr_stage[1];
assign bram_address_2[0 +: INDEX_WORDLENGTH] = bram_addr_stage[2];
assign bram_address_3[0 +: INDEX_WORDLENGTH] = bram_addr_stage[3];
assign bram_address_4[0 +: INDEX_WORDLENGTH] = bram_addr_stage[4];
assign bram_address_5[0 +: INDEX_WORDLENGTH] = bram_addr_stage[5];
assign bram_address_6[0 +: INDEX_WORDLENGTH] = bram_addr_stage[6];
assign bram_address_7[0 +: INDEX_WORDLENGTH] = bram_addr_stage[7];


generate
for (gen_i=0;gen_i<(COMP_STAGE-1);gen_i=gen_i+1) begin:comp_cell
compare_cell#(
		.MULTI_WORDLENGTH(MULTI_WORDLENGTH)
		,.THRESHOLD_WORDLENGTH(THRESHOLD_WORDLENGTH)
		,.COMP_NUMBER_WORDLENGTH(COMP_NUMBER_WORDLENGTH)
		,.OUTPUT_WORDLENGTH(OUTPUT_WORDLENGTH)
		,.INDEX_WORDLENGTH(INDEX_WORDLENGTH)
		,.UPDATE_BIT((OUTPUT_WORDLENGTH-1)-gen_i)
        ,.BRAM_DATA_WORDLENGTH(BRAM_DATA_WORDLENGTH)
        ,.BRAM_ADDR_WORDLENGTH(BRAM_ADDR_WORDLENGTH)
)comp_out(
     .clk(clk)
    ,.rst(rst)
    ,.enable_in(Enable)

	,.comp_in_sign(comp_in_sign_stage[gen_i])
	,.comp_in(comp_in_stage[gen_i])
	,.threshold_index(threshold_index_stage[gen_i])
	,.compress_data_in(compress_data_in_stage[gen_i])
	,.comp_number_in(comp_number_in_stage[gen_i])

    ,.bram_addr(bram_addr_stage[gen_i])
    ,.bram_data(bram_data_stage[gen_i])

	,.comp_out_sign(comp_in_sign_stage[gen_i+1])
    ,.comp_out(comp_in_stage[gen_i+1])
	,.updated_threshold_index(threshold_index_stage[gen_i+1])
	,.compress_data_out(compress_data_in_stage[gen_i+1])
	,.comp_number_out(comp_number_in_stage[gen_i+1])
);
end
endgenerate
assign pre_CompOut = compress_data_in_stage[COMP_STAGE-1];

always @(*) begin
    CompOut = 0;
    case(NMOD)
        0:CompOut[0 +: 2] = (comp_in_sign_stage[COMP_STAGE-1])?{1'b0,~pre_CompOut[OUTPUT_WORDLENGTH-1:7]}:{1'b1,pre_CompOut[OUTPUT_WORDLENGTH-1:7]};
		1:CompOut[0 +: 3] = (comp_in_sign_stage[COMP_STAGE-1])?{1'b0,~pre_CompOut[OUTPUT_WORDLENGTH-1:6]}:{1'b1,pre_CompOut[OUTPUT_WORDLENGTH-1:6]};
		2:CompOut[0 +: 4] = (comp_in_sign_stage[COMP_STAGE-1])?{1'b0,~pre_CompOut[OUTPUT_WORDLENGTH-1:5]}:{1'b1,pre_CompOut[OUTPUT_WORDLENGTH-1:5]};
		3:CompOut[0 +: 6] = (comp_in_sign_stage[COMP_STAGE-1])?{1'b0,~pre_CompOut[OUTPUT_WORDLENGTH-1:3]}:{1'b1,pre_CompOut[OUTPUT_WORDLENGTH-1:3]};
		4:CompOut[0 +: 8] = (comp_in_sign_stage[COMP_STAGE-1])?{1'b0,~pre_CompOut[OUTPUT_WORDLENGTH-1:1]}:{1'b1,pre_CompOut[OUTPUT_WORDLENGTH-1:1]};
		default:CompOut[0 +: 8] = (comp_in_sign_stage[COMP_STAGE-1])?{1'b0,~pre_CompOut[OUTPUT_WORDLENGTH-1:1]}:{1'b1,pre_CompOut[OUTPUT_WORDLENGTH-1:1]};
    endcase
end
endmodule