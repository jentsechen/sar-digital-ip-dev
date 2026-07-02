`timescale 1ns / 1ps
module ComMulti#(
//-----------parameter-----------------------------
parameter MULTI_WORDLENGTH = 14 //S3.10
)(
//-----------input/output ports--------------------
input[MULTI_WORDLENGTH-1:0] MultiInI,
input[MULTI_WORDLENGTH-1:0] MultiInQ,
output[MULTI_WORDLENGTH-1:0] ComMultiOutI,
output[MULTI_WORDLENGTH-1:0] ComMultiOutQ
);
//-----------wire/reg------------------------------
//-----------function------------------------------
assign ComMultiOutI = ~MultiInI+1'b1;
assign ComMultiOutQ = ~MultiInQ+1'b1;

endmodule
