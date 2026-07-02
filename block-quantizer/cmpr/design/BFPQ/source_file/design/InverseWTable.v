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
module InverseWTable(FMOD, Cw, InvW
    );
input FMOD;
input [2:0] Cw;

output reg [10:0]InvW;




wire [10:0]XInvW0[0:3]; 
wire [10:0]XInvW1[0:7]; 

assign  XInvW0[0]=11'b11100000011; 
assign  XInvW0[1]=11'b11000000001; 
assign  XInvW0[2]=11'b10100000001; 
assign  XInvW0[3]=11'b10000000000; 

assign  XInvW1[0]=11'b11110000000; 
assign  XInvW1[1]=11'b11100000011; 
assign  XInvW1[2]=11'b11010000000; 
assign  XInvW1[3]=11'b11000000001; 
assign  XInvW1[4]=11'b10110000001; 
assign  XInvW1[5]=11'b10100000001; 
assign  XInvW1[6]=11'b10010000000; 
assign  XInvW1[7]=11'b10000000000; 
//assign  XInvW1[8]=11'b10111000000; 
//assign  XInvW1[9]=11'b10110000001; 
//assign  XInvW1[10]=11'b10101000000; 
//assign  XInvW1[11]=11'b10100000101; 
//assign  XInvW1[12]=11'b10011000011; 
//assign  XInvW1[13]=11'b10010000010; 
//assign  XInvW1[14]=11'b10001000100; 
//assign  XInvW1[15]=11'b10000000000; 
///////////�ھڳ]�w��ܹ�����X////////
always @(*)begin
case(FMOD)
1'd0:begin
		case(Cw)
			4'd0:InvW=XInvW0[0];
			4'd1:InvW=XInvW0[1];
			4'd2:InvW=XInvW0[2];
			4'd3:InvW=XInvW0[3];
			default:InvW=0;
		endcase
		end 
1'd1:begin	
		case(Cw)
			4'd0:InvW=XInvW1[0];
			4'd1:InvW=XInvW1[1];
			4'd2:InvW=XInvW1[2];
			4'd3:InvW=XInvW1[3];
			4'd4:InvW=XInvW1[4];
			4'd5:InvW=XInvW1[5];
			4'd6:InvW=XInvW1[6];
			4'd7:InvW=XInvW1[7];
//			4'd8:InvW=XInvW1[8];
//			4'd9:InvW=XInvW1[9];
//			4'd10:InvW=XInvW1[10];
//			4'd11:InvW=XInvW1[11];
//			4'd12:InvW=XInvW1[12];
//			4'd13:InvW=XInvW1[13];
//			4'd14:InvW=XInvW1[14];
//			4'd15:InvW=XInvW1[15];
            default: InvW = 0;
		endcase
		end
	endcase
end

///////////�ھڳ]�w��ܹ�����X////////


endmodule
