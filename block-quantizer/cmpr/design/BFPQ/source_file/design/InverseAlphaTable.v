`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:51:46 11/15/2018 
// Design Name: 
// Module Name:    AlphaTable 
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
module InverseAlphaTable(MMOD, BMOD, InverseAlpha
    );
input [2:0] MMOD;
input [1:0] BMOD;

output reg [9:0] InverseAlpha;


always@(*)
case(BMOD)
	2'd2:case(MMOD)
			3'd2:InverseAlpha=10'b0111100111;
			3'd3:InverseAlpha=10'b0111110101;
			3'd4:InverseAlpha=10'b0111111101;
			default:InverseAlpha=10'b1000000000;
		  endcase
	default:InverseAlpha=10'b1000000000;
endcase


endmodule
