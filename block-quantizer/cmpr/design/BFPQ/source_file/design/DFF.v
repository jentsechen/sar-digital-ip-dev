`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:56:05 09/17/2018 
// Design Name: 
// Module Name:    DFF 
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
module DFF(out, in, clk, Enable, rst
    );
parameter wordlength=12;
input clk, rst, Enable;
input [wordlength-1:0] in;
output reg [wordlength-1:0] out;


always@(posedge clk or posedge rst)
if (rst)
	out<=0;
else if(Enable)
	out<=in;
else
	out<=out;


endmodule
