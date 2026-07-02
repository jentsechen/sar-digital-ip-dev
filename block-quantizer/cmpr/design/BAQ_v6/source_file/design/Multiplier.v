`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2023 07:34:12 PM
// Design Name: 
// Module Name: Multiplier
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


module Multiplier #(
//-----------parameter-----------------------------
parameter ADC_WORDLENGTH= 14,         //signed
parameter ADC_FRAC_WORDLENGTH = 11,
parameter SCALING_WORDLENGTH = 17,    //unsigned
parameter SCALING_FRAC_WORDLENGTH = 9,
parameter MULTI_WORDLENGTH = 14,
parameter MULTI_FRAC_WORDLENGTH = 10,

localparam TEMPMULTIPICAND_WORDLENGTH = SCALING_WORDLENGTH + 1, //18
localparam TEMP_FRAC_WORDLENGTH = ADC_FRAC_WORDLENGTH+SCALING_FRAC_WORDLENGTH,//20
localparam MULTI_LSB_BIT = TEMP_FRAC_WORDLENGTH - MULTI_FRAC_WORDLENGTH,//10
localparam MULTI_MSB_BIT = MULTI_LSB_BIT + MULTI_WORDLENGTH -1,//23



localparam TEMPMULTI_WORDLENGTH = ADC_WORDLENGTH + TEMPMULTIPICAND_WORDLENGTH //32
)(    
//-----------input/output ports--------------------
input signed[SCALING_WORDLENGTH-1:0]Multiplicand,
input signed[ADC_WORDLENGTH-1:0]MultiInI,
input signed[ADC_WORDLENGTH-1:0]MultiInQ,

output signed [MULTI_WORDLENGTH-1:0]MultiOutI,
output signed [MULTI_WORDLENGTH-1:0]MultiOutQ
);
//-----------wire/reg------------------------------
wire signed [TEMPMULTIPICAND_WORDLENGTH-1:0]temp_Multiplicand;
wire signed [TEMPMULTI_WORDLENGTH-1:0]temp_MultiOutI,temp_MultiOutQ;
//-----------function------------------------------
assign temp_Multiplicand = {1'b0,Multiplicand};    //add signed bit
assign temp_MultiOutI = temp_Multiplicand*MultiInI;     //S6.9*S2.11=SS8.20 -> 30bits -> 29 bits
assign temp_MultiOutQ = temp_Multiplicand*MultiInQ;     //S6.9*S2.11=SS8.20 -> 30bits -> 29 bits

assign MultiOutI = {temp_MultiOutI[MULTI_MSB_BIT:MULTI_LSB_BIT]};//S3.10
assign MultiOutQ = {temp_MultiOutQ[MULTI_MSB_BIT:MULTI_LSB_BIT]};


endmodule









