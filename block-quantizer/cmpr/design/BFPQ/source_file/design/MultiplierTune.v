`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:18:16 08/31/2018 
// Design Name: 
// Module Name:    Multiplier 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module MultiplierTune(in, InverseAlpha, out
    );
input [12:0] in;//2.11
input [9:0] InverseAlpha;//1.9
output [13:0]out;//2.12
wire [21:0] out_b;//2.20

assign out_b=in*InverseAlpha;
assign out=out_b[21:8];



endmodule
