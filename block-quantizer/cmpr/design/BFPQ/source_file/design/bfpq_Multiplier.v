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
module bfpq_Multiplier(in, InvW, out
    );
input [12:0] in;//2.11
input [10:0] InvW;//1.10
output [17:0]out;//3.15
wire [23:0] out_b;//3.21

assign out_b=in*InvW;
assign out=out_b[23:6];


endmodule
