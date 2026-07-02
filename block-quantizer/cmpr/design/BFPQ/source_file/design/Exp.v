`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:34:21 08/29/2018 
// Design Name: 
// Module Name:    Exp 
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
module Exp(in, ThresholdExp1, ThresholdExp2, ThresholdExp3, ThresholdExp4, ThresholdExp5, ThresholdExp6, ThresholdExp7, Ce
    );

input [13:0] in;//2.12
input [11:0] ThresholdExp1, ThresholdExp2, ThresholdExp3, ThresholdExp4, ThresholdExp5, ThresholdExp6, ThresholdExp7;//3.9
output reg [2:0] Ce;
wire signed [14:0] out, out1, out2, out3, out4, out5, out6;//3.12
reg judge0, judge1, judge2, judge3, judge4, judge5, judge6;

////////////輸入訊號與邊界相減//////////
assign out={ThresholdExp1,3'b000}-in;
assign out1={ThresholdExp2,3'b000}-in;
assign out2={ThresholdExp3,3'b000}-in;
assign out3={ThresholdExp4,3'b000}-in;
assign out4={ThresholdExp5,3'b000}-in;
assign out5={ThresholdExp6,3'b000}-in;
assign out6={ThresholdExp7,3'b000}-in;
////////////輸入訊號與邊界相減//////////
//assign out3=in-ThresholdExp4;


///////根據相減後的最高位元判斷操作動作////////////
always@(*)begin
if (out[14]==0)
    judge0=1'b1;
else
    judge0=1'b0;
end

always@(*)begin
if (out1[14]==0)
    judge1=1;
else
    judge1=0;
end

always@(*)begin
if (out2[14]==0)
    judge2=1;
else
    judge2=0;
end

always@(*)begin
if (out3[14]==0)
    judge3=1'b1;
else
    judge3=1'b0;
end

always@(*)begin
if (out4[14]==0)
    judge4=1;
else
    judge4=0;
end

always@(*)begin
if (out5[14]==0)
    judge5=1;
else
    judge5=0;
end

always@(*)begin
if (out6[14]==0)
    judge6=1;
else
    judge6=0;
end
///////根據相減後的最高位元判斷操作動作////////////
//always@(*)begin
//if (out3<0)
//    judge3=1;
//else
//    judge3=0;
//end
///////根據操作動作選擇輸出////////////////
always@(*)begin
if (judge0==1)
    Ce=3'd0;
else if (judge1==1)
    Ce=3'd1;
else if (judge2==1)
    Ce=3'd2;
else if (judge3==1)
    Ce=3'd3;
else if (judge4==1)
    Ce=3'd4;
else if (judge5==1)
    Ce=3'd5;
else if (judge6==1)
    Ce=3'd6;
else
    Ce=3'd7;
end
///////根據操作動作選擇輸出////////////////
endmodule
