`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:14:31 08/28/2018 
// Design Name: 
// Module Name:    ExpTable 
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
module ExpTable(MMOD, bound1, bound2, bound3, bound4, bound5, bound6, bound7/*, bound8*/
    );
parameter WORD_LENGTH=4'd14;


input [2:0]MMOD;

output reg [11:0]bound1, bound2, bound3, bound4, bound5, bound6, bound7;//, bound8;

/////////M=2的記憶體
wire [11:0]XThreshold2[0:6];
/////////M=3的記憶體
wire [11:0]XThreshold3[0:6]; 
/////////M=4的記憶體
wire [11:0]XThreshold4[0:6];
/////////M=6的記憶體
wire [11:0]XThreshold6[0:6];
/////////M=8的記憶體
wire [11:0]XThreshold8[0:6];

assign  XThreshold2[0]=12'b000000001110; 
assign  XThreshold2[1]=12'b000000011100; 
assign  XThreshold2[2]=12'b000000111001; 
assign  XThreshold2[3]=12'b000001110011; 
assign  XThreshold2[4]=12'b000011100111; 
assign  XThreshold2[5]=12'b000111001111; 
assign  XThreshold2[6]=12'b001110011110; 
//assign  XThreshold2[7]=12'b011100111101; 


assign  XThreshold3[0]=12'b000000010001; 
assign  XThreshold3[1]=12'b000000100011; 
assign  XThreshold3[2]=12'b000001000110; 
assign  XThreshold3[3]=12'b000010001101; 
assign  XThreshold3[4]=12'b000100011010; 
assign  XThreshold3[5]=12'b001000110100; 
assign  XThreshold3[6]=12'b010001101001; 
//assign  XThreshold3[7]=12'b100011010011; 


assign  XThreshold4[0]=12'b000000010011; 
assign  XThreshold4[1]=12'b000000100110; 
assign  XThreshold4[2]=12'b000001001100; 
assign  XThreshold4[3]=12'b000010011000; 
assign  XThreshold4[4]=12'b000100110000; 
assign  XThreshold4[5]=12'b001001100000; 
assign  XThreshold4[6]=12'b010011000000; 
//assign  XThreshold4[7]=12'b100110000000; 

assign  XThreshold6[0]=12'b000000010101; 
assign  XThreshold6[1]=12'b000000101011; 
assign  XThreshold6[2]=12'b000001010110; 
assign  XThreshold6[3]=12'b000010101101; 
assign  XThreshold6[4]=12'b000101011011; 
assign  XThreshold6[5]=12'b001010110111; 
assign  XThreshold6[6]=12'b010101101110; 
//assign  XThreshold6[7]=12'b101011011100; 

assign  XThreshold8[0]=12'b000000010110; 
assign  XThreshold8[1]=12'b000000101100; 
assign  XThreshold8[2]=12'b000001011001; 
assign  XThreshold8[3]=12'b000010110011; 
assign  XThreshold8[4]=12'b000101100111; 
assign  XThreshold8[5]=12'b001011001110; 
assign  XThreshold8[6]=12'b010110011100; 
//assign  XThreshold8[7]=12'b101100111001; 

/////////根據MMOD選擇對應的輸出///////////
always @(*)begin
case(MMOD)
3'd0:begin
		bound1=XThreshold2[0];
		bound2=XThreshold2[1];
		bound3=XThreshold2[2];
		bound4=XThreshold2[3];
		bound5=XThreshold2[4];
		bound6=XThreshold2[5];
		bound7=XThreshold2[6];
//		bound8=XThreshold2[7];
		end
3'd1:begin
		bound1=XThreshold3[0];
		bound2=XThreshold3[1];
		bound3=XThreshold3[2];
		bound4=XThreshold3[3];
		bound5=XThreshold3[4];
		bound6=XThreshold3[5];
		bound7=XThreshold3[6];
//		bound8=XThreshold3[7];
		end
3'd2:begin
		bound1=XThreshold4[0];
		bound2=XThreshold4[1];
		bound3=XThreshold4[2];
		bound4=XThreshold4[3];
		bound5=XThreshold4[4];
		bound6=XThreshold4[5];
		bound7=XThreshold4[6];
//		bound8=XThreshold4[7];
		end
3'd3:begin
		bound1=XThreshold6[0];
		bound2=XThreshold6[1];
		bound3=XThreshold6[2];
		bound4=XThreshold6[3];
		bound5=XThreshold6[4];
		bound6=XThreshold6[5];
		bound7=XThreshold6[6];
//		bound8=XThreshold2[7];
		end
3'd4:begin
		bound1=XThreshold8[0];
		bound2=XThreshold8[1];
		bound3=XThreshold8[2];
		bound4=XThreshold8[3];
		bound5=XThreshold8[4];
		bound6=XThreshold8[5];
		bound7=XThreshold8[6];
//		bound8=XThreshold8[7];
		end
default:
		begin
		bound1=0;
		bound2=0;
		bound3=0;
		bound4=0;
		bound5=0;
		bound6=0;
		bound7=0;
//		bound8=0;
		end
endcase
end



endmodule
