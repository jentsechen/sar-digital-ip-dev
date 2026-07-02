`timescale 1ns / 1ps
//*******description***************************
//sum all of block data variance and output the result
//*********************************************
module Accumulator #(
//-----------parameter-----------------------------
parameter SQU_WORDLENGTH = 19,
parameter PARALLEL_BLOCK_SIZE_WORDLENGTH = 8,
parameter ACC_WORDLENGTH = 29,
parameter PARALLEL_NUMBER = 4,

localparam ADD_CNT = $clog2(PARALLEL_NUMBER)+1+2,
localparam ADD_TOTAL_STAGE = $clog2(PARALLEL_NUMBER)+1,
localparam ADD_IN_WORDLENGTH = ACC_WORDLENGTH*PARALLEL_NUMBER*2 //I&Q
)(
//-----------input/output ports--------------------
input clk,
input rst,
input [PARALLEL_BLOCK_SIZE_WORDLENGTH-1:0]DB_BUF_counter,
input [SQU_WORDLENGTH*PARALLEL_NUMBER-1:0]In_seq_I,
input [SQU_WORDLENGTH*PARALLEL_NUMBER-1:0]In_seq_Q,
input Enable,

output reg [ACC_WORDLENGTH-1:0]Out_sum //total sum of squarer ouptut
);
//-----------wire/reg------------------------------
reg [ACC_WORDLENGTH-1:0]temp_sum;
// reg [ACC_WORDLENGTH-1:0]temp_In_sum[0:PARALLEL_NUMBER-1];
// reg [ACC_WORDLENGTH-1:0]temp_In_sumD[0:PARALLEL_NUMBER-1];
// wire[SQU_WORDLENGTH-1:0]In_set_I[0:PARALLEL_NUMBER-1];
// wire[SQU_WORDLENGTH-1:0]In_set_Q[0:PARALLEL_NUMBER-1];

wire [ADD_IN_WORDLENGTH-1:0]In_ADD_seq[0:ADD_TOTAL_STAGE]; //Add initial stage
wire [ADD_IN_WORDLENGTH-1:0]In_ADD_seq_D[0:ADD_TOTAL_STAGE];
genvar gen_i;
integer i;
//-----------function------------------------------
generate
    // for (gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1) begin
    //     assign In_set_I[gen_i] = In_seq_I[SQU_WORDLENGTH*gen_i +: SQU_WORDLENGTH];
    //     assign In_set_Q[gen_i] = In_seq_Q[SQU_WORDLENGTH*gen_i +: SQU_WORDLENGTH];
    // end
    for (gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1) begin
        assign In_ADD_seq[0][ACC_WORDLENGTH*(gen_i*2)   +: ACC_WORDLENGTH] = {{(ACC_WORDLENGTH-SQU_WORDLENGTH){0}},In_seq_I[SQU_WORDLENGTH*gen_i +: SQU_WORDLENGTH]};
        assign In_ADD_seq[0][ACC_WORDLENGTH*(gen_i*2+1) +: ACC_WORDLENGTH] = {{(ACC_WORDLENGTH-SQU_WORDLENGTH){0}},In_seq_Q[SQU_WORDLENGTH*gen_i +: SQU_WORDLENGTH]};
    end
    for (gen_i=0;gen_i<ADD_TOTAL_STAGE+1;gen_i=gen_i+1) begin
        SingleFF #(.SFF_Wordlength(ADD_IN_WORDLENGTH))INaddD_ini(.Enable(Enable),.rst(rst),.DInput(In_ADD_seq[gen_i]),.QOutput(In_ADD_seq_D[gen_i]),.clk(clk));
    end
    for (gen_i=0;gen_i<ADD_TOTAL_STAGE;gen_i=gen_i+1) begin //gen_i = 0 1 2/0 1 2 3 4 5 6
        Add_pipe #(
            .ACC_WORDLENGTH(ACC_WORDLENGTH),
            .ADD_TOTAL_STAGE(ADD_TOTAL_STAGE),// 3/7
            .ADD_STAGE_NUMBER(gen_i+1)// 1 2 3/1 2 3 4 5 6 7
        )ADD0(
        .in1(In_ADD_seq_D[gen_i]),//0 1 2 /0 1 2 3 4 5 6
        .out1(In_ADD_seq[gen_i+1])//1 2 3 /1 2 3 4 5 6 7
        );
    end
endgenerate

// always @(*) begin
//     temp_In_sum[0] = temp_In_sumD[0];
//     for (i=1;i<PARALLEL_NUMBER;i=i+1) begin
//         temp_In_sum[i] = temp_In_sum[i-1] + temp_In_sumD[i];
//     end
// end

// always @(posedge clk or posedge rst)begin
//     if(rst) begin
//         for (i=0;i<PARALLEL_NUMBER;i=i+1) begin
//             temp_In_sumD[i] <= 0;
//         end
//     end
//     else begin
//         if(Enable)begin
//             for (i=0;i<PARALLEL_NUMBER;i=i+1) begin
//                 temp_In_sumD[i] <= (In_set_I[i]+In_set_Q[i]);
//             end
//         end
//         else begin
//             for (i=0;i<PARALLEL_NUMBER;i=i+1) begin
//                  temp_In_sumD[i] <= temp_In_sumD[i];
//             end
//         end
//     end
// end
wire [ACC_WORDLENGTH-1:0]look_In_ADD_seq_D;
assign look_In_ADD_seq_D = In_ADD_seq_D[ADD_TOTAL_STAGE][0 +: ACC_WORDLENGTH];
always @(posedge clk or posedge rst)begin
    if(rst) temp_sum <= 0;
    else begin
        if(Enable)begin
            if (DB_BUF_counter == ADD_CNT) temp_sum <=        0+In_ADD_seq_D[ADD_TOTAL_STAGE][0 +: ACC_WORDLENGTH];
            else                     temp_sum <= temp_sum+In_ADD_seq_D[ADD_TOTAL_STAGE][0 +: ACC_WORDLENGTH];
        end
        else temp_sum <= temp_sum;
    end
end

always@(*) begin
    if(DB_BUF_counter == (ADD_CNT-1)) begin
	    Out_sum =  temp_sum+In_ADD_seq_D[ADD_TOTAL_STAGE][0 +: ACC_WORDLENGTH];
	end
	else begin
	    Out_sum = 29'b0;
	end
end
endmodule









