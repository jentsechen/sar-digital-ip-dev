`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2023 01:33:24 PM
// Design Name: 
// Module Name: Squarer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Squarer #(
//-----------parameter-----------------------------
parameter ADC_WORDLENGTH = 14,
parameter ADC_FRAC_WORDLENGTH = 11,
parameter SQU_WORDLENGTH = 19,      //U5.14
parameter SQU_FRAC_WORDLENGTH = 14,

localparam SQU_TEMPSUM_WORDLENGTH = ADC_WORDLENGTH*2,
localparam SQU_TEMPSUM_FRAC_WORDLENGTH = ADC_FRAC_WORDLENGTH*2,           //22
localparam SQU_LSB_BIT = SQU_TEMPSUM_FRAC_WORDLENGTH-SQU_FRAC_WORDLENGTH //22-14=8-> remove[7:0]
)(
//-----------input/output ports--------------------
input signed [ADC_WORDLENGTH-1:0]inI, //S2.11
input signed [ADC_WORDLENGTH-1:0]inQ, //S2.11
output reg[SQU_WORDLENGTH-1:0]outI,   //U5.14
output reg[SQU_WORDLENGTH-1:0]outQ    //U5.14
);
//-----------wire/reg------------------------------
wire [SQU_TEMPSUM_WORDLENGTH-1:0]temp_outI; //U6.22
wire [SQU_TEMPSUM_WORDLENGTH-1:0]temp_outQ;
//-----------function------------------------------
assign temp_outI = inI*inI; //U6.22 -> SS4.22 = S2.11*S2.11
assign temp_outQ = inQ*inQ;

always@(temp_outI or temp_outQ) begin
    outI = temp_outI[SQU_LSB_BIT +: SQU_WORDLENGTH]; //U5.14
    outQ = temp_outQ[SQU_LSB_BIT +: SQU_WORDLENGTH];
end

endmodule
