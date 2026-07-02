`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:57:00 08/28/2018 
// Design Name: 
// Module Name:    WTable 
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
module WTable(FMOD, bound0, bound1, bound2, bound3, bound4, bound5, bound6/*, bound7, bound8, bound9, bound10, bound11, bound12, bound13, bound14, bound15*/
//Wscaling0, Wscaling1, Wscaling2, Wscaling3, Wscaling4, Wscaling5, Wscaling6, Wscaling7, Wscaling8, Wscaling9, Wscaling10, Wscaling11, Wscaling12, Wscaling13, Wscaling14, Wscaling15
    );
input FMOD;

output reg [8:0]bound0, bound1, bound2, bound3, bound4, bound5, bound6;//, bound7, bound8, bound9, bound10, bound11, bound12, bound13, bound14;//, bound15;
//output reg [11:0]Wscaling0, Wscaling1, Wscaling2, Wscaling3, Wscaling4, Wscaling5, Wscaling6, Wscaling7, Wscaling8, Wscaling9, Wscaling10, Wscaling11, Wscaling12, Wscaling13, Wscaling14, Wscaling15;
wire [8:0]XW0[0:2];//0.9
wire [8:0]XW1[0:6];


assign  XW0[0]=9'b100100100; 
assign  XW0[1]=9'b101010101; 
assign  XW0[2]=9'b110011001; 
//assign  XW0[3]=9'b100000000; 

assign  XW1[0]=9'b100010001; 
assign  XW1[1]=9'b100100100; 
assign  XW1[2]=9'b100111011; 
assign  XW1[3]=9'b101010101; 
assign  XW1[4]=9'b101110100; 
assign  XW1[5]=9'b110011001; 
assign  XW1[6]=9'b111000111; 
//assign  XW1[7]=9'b010101010; 
//assign  XW1[8]=9'b010110010; 
//assign  XW1[9]=9'b010111010; 
//assign  XW1[10]=9'b011000011; 
//assign  XW1[11]=9'b011001100; 
//assign  XW1[12]=9'b011010111; 
//assign  XW1[13]=9'b011100011; 
//assign  XW1[14]=9'b011110000; 
//assign  XW1[15]=9'b100000000; 

//assign  XWscaling0[0]=11'b11100011100; 
//assign  XWscaling0[1]=11'b11000011000; 
//assign  XWscaling0[2]=11'b10100000101; 
//assign  XWscaling0[3]=11'b10000000000; 
//
//assign  XWscaling1[0]=11'b11111000001; 
//assign  XWscaling1[1]=11'b11110000111; 
//assign  XWscaling1[2]=11'b11101010000; 
//assign  XWscaling1[3]=11'b11100011100; 
//assign  XWscaling1[4]=11'b11011101011; 
//assign  XWscaling1[5]=11'b11010010000; 
//assign  XWscaling1[6]=11'b11001100110; 
//assign  XWscaling1[7]=11'b11000011000; 
//assign  XWscaling1[8]=11'b10111010001; 
//assign  XWscaling1[9]=11'b10110010000; 
//assign  XWscaling1[10]=11'b10101010101; 
//assign  XWscaling1[11]=11'b10100000101; 
//assign  XWscaling1[12]=11'b10011010100; 
//assign  XWscaling1[13]=11'b10010010010; 
//assign  XWscaling1[14]=11'b10001000100; 
//assign  XWscaling1[15]=11'b10000000000;

/////////////////根據FMOD雪則對應的輸出//////////////
always @(*)begin
case(FMOD)
1'd0:begin
		bound0=XW0[0];
		bound1=XW0[1];
		bound2=XW0[2];
		bound3=0;
//		bound3=XW0[3];
		bound4=0;
		bound5=0;
		bound6=0;
//		bound7=0;
//		bound8=0;
//		bound9=0;
//		bound10=0;
//		bound11=0;
//		bound12=0;
//		bound13=0;
//		bound14=0;
//		bound15=0;
		
//		Wscaling0=XWscaling0[0];
//		Wscaling1=XWscaling0[1];
//		Wscaling2=XWscaling0[2];
//		Wscaling3=XWscaling0[3];
//		Wscaling4=0; 
//		Wscaling5=0; 
//		Wscaling6=0; 
//		Wscaling7=0; 
//		Wscaling8=0; 
//		Wscaling9=0; 
//		Wscaling10=0; 
//		Wscaling11=0; 
//		Wscaling12=0; 
//		Wscaling13=0; 
//		Wscaling14=0; 
//		Wscaling15=0; 
		end 
1'd1:begin
		bound0=XW1[0]; 
		bound1=XW1[1]; 
		bound2=XW1[2]; 
		bound3=XW1[3]; 
		bound4=XW1[4]; 
		bound5=XW1[5]; 
		bound6=XW1[6]; 
//		bound7=XW1[7]; 
//		bound8=XW1[8]; 
//		bound9=XW1[9]; 
//		bound10=XW1[10]; 
//		bound11=XW1[11]; 
//		bound12=XW1[12]; 
//		bound13=XW1[13]; 
//		bound14=XW1[14]; 
//		bound15=XW1[15]; 
		
//		Wscaling0=XWscaling1[0];
//		Wscaling1=XWscaling1[1]; 
//		Wscaling2=XWscaling1[2]; 
//		Wscaling3=XWscaling1[3]; 
//		Wscaling4=XWscaling1[4]; 
//		Wscaling5=XWscaling1[5]; 
//		Wscaling6=XWscaling1[6]; 
//		Wscaling7=XWscaling1[7]; 
//		Wscaling8=XWscaling1[8]; 
//		Wscaling9=XWscaling1[9]; 
//		Wscaling10=XWscaling1[10]; 
//		Wscaling11=XWscaling1[11]; 
//		Wscaling12=XWscaling1[12]; 
//		Wscaling13=XWscaling1[13]; 
//		Wscaling14=XWscaling1[14]; 
//		Wscaling15=XWscaling1[15]; 
		end
	endcase
end


endmodule
