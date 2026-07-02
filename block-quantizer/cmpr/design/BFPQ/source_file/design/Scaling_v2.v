`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:38:36 08/29/2018 
// Design Name: 
// Module Name:    Scaling 
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
module Scaling_v2(in, FMOD, Ce, A, ThresholdW0, ThresholdW1, ThresholdW2, ThresholdW3, ThresholdW4, ThresholdW5, ThresholdW6, clk, rst, Enable/*, ThresholdW7, ThresholdW8, ThresholdW9, ThresholdW10
, ThresholdW11, ThresholdW12, ThresholdW13, ThresholdW14, ThresholdW15*/, Cw);

input clk, rst, Enable;
input [13:0] in;//2.12
input FMOD;
input [2:0]  Ce;
input [8:0]  ThresholdW0, ThresholdW1, ThresholdW2, ThresholdW3, ThresholdW4, ThresholdW5, ThresholdW6;//, ThresholdW7, ThresholdW8, ThresholdW9, ThresholdW10, ThresholdW11, ThresholdW12, ThresholdW13, ThresholdW14;//0.9, ThresholdW15

input [11:0] A;//0.12
output reg [2:0] Cw;
wire [20:0] bound0, bound1, bound2, bound3, bound4, bound5, bound6;//0.21
wire [11:0] bound0_trun, bound1_trun, bound2_trun, bound3_trun, bound4_trun, bound5_trun, bound6_trun;//0.12
reg  [11:0] bound0_DFF, bound1_DFF, bound2_DFF, bound3_DFF, bound4_DFF, bound5_DFF, bound6_DFF;//0.12
wire [15:0] bound0_addbit, bound1_addbit, bound2_addbit, bound3_addbit, bound4_addbit, bound5_addbit, bound6_addbit;//0.16
reg  [18:0] bound0_shift, bound1_shift, bound2_shift, bound3_shift, bound4_shift, bound5_shift, bound6_shift;//3.16
wire [14:0] bound0_shift_trun, bound1_shift_trun, bound2_shift_trun, bound3_shift_trun, bound4_shift_trun, bound5_shift_trun, bound6_shift_trun;//3.12

wire  signed[14:0] out0, out1, out2, out3, out4, out5, out6;//, out7, out8, out9, out10, out11, out12, out13, out14;//, out15;

reg 	judge0, judge1, judge2, judge3, judge4, judge5, judge6;//, judge7, judge8, judge9 ,judge10, judge11, judge12, judge13, judge14;//, judge15;
reg [2:0] Ce_right_shift;


//assign ThresholdW0_addbit={ThresholdW0,4'b0000};
//assign ThresholdW1_addbit={ThresholdW1,4'b0000};
//assign ThresholdW2_addbit={ThresholdW2,4'b0000};
//assign ThresholdW3_addbit={ThresholdW3,4'b0000};
//assign ThresholdW4_addbit={ThresholdW4,4'b0000};
//assign ThresholdW5_addbit={ThresholdW5,4'b0000};
//assign ThresholdW6_addbit={ThresholdW6,4'b0000};
//assign ThresholdW7_addbit={ThresholdW7,4'b0000};
//assign ThresholdW8_addbit={ThresholdW8,4'b0000};
//assign ThresholdW9_addbit={ThresholdW9,4'b0000};
//assign ThresholdW10_addbit={ThresholdW10,4'b0000};
//assign ThresholdW11_addbit={ThresholdW11,4'b0000};
//assign ThresholdW12_addbit={ThresholdW12,4'b0000};
//assign ThresholdW13_addbit={ThresholdW13,4'b0000};
//assign ThresholdW14_addbit={ThresholdW14,4'b0000};

///////將負號的指數項轉到正確的右移值/////////
always@(*) begin
	case(Ce)
		3'd0:Ce_right_shift=3'd4;
		3'd1:Ce_right_shift=3'd3;
		3'd2:Ce_right_shift=3'd2;
		3'd3:Ce_right_shift=3'd1;
		default: Ce_right_shift=3'd0;
	endcase
end
///////將負號的指數項轉到正確的右移值/////////	

//always@(*) begin
//	if(Ce[2]==0) begin
//		bound0=(ThresholdW0_addbit>>Ce_right_shift)*A;
//		bound1=(ThresholdW0_addbit>>Ce_right_shift)*A;
//		bound2=(ThresholdW0_addbit>>Ce_right_shift)*A;
//		bound3=(ThresholdW0_addbit>>Ce_right_shift)*A;
//		bound4=(ThresholdW0_addbit>>Ce_right_shift)*A;
//		bound5=(ThresholdW0_addbit>>Ce_right_shift)*A;
//		bound6=(ThresholdW0_addbit>>Ce_right_shift)*A;
////		bound7=(ThresholdW0_addbit>>Ce_right_shift)*A;
////		bound8=(ThresholdW0_addbit>>Ce_right_shift)*A;
////		bound9=(ThresholdW0_addbit>>Ce_right_shift)*A;
////		bound10=(ThresholdW0_addbit>>Ce_right_shift)*A;
////		bound11=(ThresholdW0_addbit>>Ce_right_shift)*A;
////		bound12=(ThresholdW0_addbit>>Ce_right_shift)*A;
////		bound13=(ThresholdW0_addbit>>Ce_right_shift)*A;
////		bound14=(ThresholdW0_addbit>>Ce_right_shift)*A;
//		end
//	else begin
//		bound0=(ThresholdW0_addbit<<Ce[1:0])*A;
//		bound1=(ThresholdW1_addbit<<Ce[1:0])*A;
//		bound2=(ThresholdW2_addbit<<Ce[1:0])*A;
//		bound3=(ThresholdW3_addbit<<Ce[1:0])*A;
//		bound4=(ThresholdW4_addbit<<Ce[1:0])*A;
//		bound5=(ThresholdW5_addbit<<Ce[1:0])*A;
//		bound6=(ThresholdW6_addbit<<Ce[1:0])*A;
////		bound7=(ThresholdW7_addbit<<Ce[1:0])*A;
////		bound8=(ThresholdW8_addbit<<Ce[1:0])*A;
////		bound9=(ThresholdW9_addbit<<Ce[1:0])*A;
////		bound10=(ThresholdW10_addbit<<Ce[1:0])*A;
////		bound11=(ThresholdW11_addbit<<Ce[1:0])*A;
////		bound12=(ThresholdW12_addbit<<Ce[1:0])*A;
////		bound13=(ThresholdW13_addbit<<Ce[1:0])*A;
////		bound14=(ThresholdW14_addbit<<Ce[1:0])*A;
//	end
//end

//////////////相乘得到設定下的邊界//////////
assign bound0=ThresholdW0*A;
assign bound1=ThresholdW1*A;
assign bound2=ThresholdW2*A;
assign bound3=ThresholdW3*A;
assign bound4=ThresholdW4*A;
assign bound5=ThresholdW5*A;
assign bound6=ThresholdW6*A;
//////////////相乘得到設定下的邊界//////////

//////////////truncate///////////
assign bound0_trun=bound0[20:9];
assign bound1_trun=bound1[20:9];
assign bound2_trun=bound2[20:9];
assign bound3_trun=bound3[20:9];
assign bound4_trun=bound4[20:9];
assign bound5_trun=bound5[20:9];
assign bound6_trun=bound6[20:9];
//////////////truncate///////////

always@(posedge clk or posedge rst) begin
if(rst) begin
	bound0_DFF<=12'd0;
	bound1_DFF<=12'd0;
	bound2_DFF<=12'd0;
	bound3_DFF<=12'd0;
	bound4_DFF<=12'd0;
	bound5_DFF<=12'd0;
	bound6_DFF<=12'd0;
	end
else if(Enable) begin
	bound0_DFF<=bound0_trun;
	bound1_DFF<=bound1_trun;
	bound2_DFF<=bound2_trun;
	bound3_DFF<=bound3_trun;
	bound4_DFF<=bound4_trun;
	bound5_DFF<=bound5_trun;
	bound6_DFF<=bound6_trun;
	end
else begin
	bound0_DFF<=bound0_DFF;
	bound1_DFF<=bound1_DFF;
	bound2_DFF<=bound2_DFF;
	bound3_DFF<=bound3_DFF;
	bound4_DFF<=bound4_DFF;
	bound5_DFF<=bound5_DFF;
	bound6_DFF<=bound6_DFF;
	end
end

assign bound0_addbit={bound0_DFF,4'b0000};
assign bound1_addbit={bound1_DFF,4'b0000};
assign bound2_addbit={bound2_DFF,4'b0000};
assign bound3_addbit={bound3_DFF,4'b0000};
assign bound4_addbit={bound4_DFF,4'b0000};
assign bound5_addbit={bound5_DFF,4'b0000};
assign bound6_addbit={bound6_DFF,4'b0000};

/////////////將邊界左移或右移至該exponent///////////////
always@(*) begin
	if(Ce[2]==0) begin
		bound0_shift=(bound0_addbit>>Ce_right_shift);
		bound1_shift=(bound0_addbit>>Ce_right_shift);
		bound2_shift=(bound0_addbit>>Ce_right_shift);
		bound3_shift=(bound0_addbit>>Ce_right_shift);
		bound4_shift=(bound0_addbit>>Ce_right_shift);
		bound5_shift=(bound0_addbit>>Ce_right_shift);
		bound6_shift=(bound0_addbit>>Ce_right_shift);
		end
	else begin
		bound0_shift=(bound0_addbit<<Ce[1:0]);
		bound1_shift=(bound1_addbit<<Ce[1:0]);
		bound2_shift=(bound2_addbit<<Ce[1:0]);
		bound3_shift=(bound3_addbit<<Ce[1:0]);
		bound4_shift=(bound4_addbit<<Ce[1:0]);
		bound5_shift=(bound5_addbit<<Ce[1:0]);
		bound6_shift=(bound6_addbit<<Ce[1:0]);
	end
end
/////////////將邊界左移或右移至該exponent///////////////

assign bound0_shift_trun=bound0_shift[18:4];
assign bound1_shift_trun=bound1_shift[18:4];
assign bound2_shift_trun=bound2_shift[18:4];
assign bound3_shift_trun=bound3_shift[18:4];
assign bound4_shift_trun=bound4_shift[18:4];
assign bound5_shift_trun=bound5_shift[18:4];
assign bound6_shift_trun=bound6_shift[18:4];



////////////輸入訊號與邊界相減//////////
assign out0=bound0_shift_trun-in;
assign out1=bound1_shift_trun-in;
assign out2=bound2_shift_trun-in;
assign out3=bound3_shift_trun-in;
assign out4=bound4_shift_trun-in;
assign out5=bound5_shift_trun-in;
assign out6=bound6_shift_trun-in;
////////////輸入訊號與邊界相減//////////
//assign out7=ThresholdW7_trun-in;
//assign out8=ThresholdW8_trun-in;
//assign out9=ThresholdW9_trun-in;
//assign out10=ThresholdW10_trun-in;
//assign out11=ThresholdW11_trun-in;
//assign out12=ThresholdW12_trun-in;
//assign out13=ThresholdW13_trun-in;
//assign out14=ThresholdW14_trun-in;
//assign out15=in_addbit-ThresholdW15_trun;



//always@(*)begin
//if (out0<0)
//    judge0=1'b1;
//else
//    judge0=1'b0;
//end
//
//always@(*)begin
//if (out1<0)
//    judge1=1;
//else
//    judge1=0;
//end
//
//always@(*)begin
//if (out2<0)
//    judge2=1;
//else
//    judge2=0;
//end
//
//always@(*)begin
//if (out3<0)
//    judge3=1;
//else
//    judge3=0;
//end
//
//always@(*)begin
//if (out4<0)
//    judge4=1;
//else
//    judge4=0;
//end
//
//always@(*)begin
//if (out5<0)
//    judge5=1;
//else
//    judge5=0;
//end
//
//always@(*)begin
//if (out6<0)
//    judge6=1;
//else
//    judge6=0;
//end
//
//always@(*)begin
//if (out7<0)
//    judge7=1;
//else
//    judge7=0;
//end
//
//always@(*)begin
//if (out8<0)
//    judge8=1;
//else
//    judge8=0;
//end
//
//always@(*)begin
//if (out9<0)
//    judge9=1;
//else
//    judge9=0;
//end
//
//always@(*)begin
//if (out10<0)
//    judge10=1;
//else
//    judge10=0;
//end
//
//always@(*)begin
//if (out11<0)
//    judge11=1;
//else
//    judge11=0;
//end
//
//always@(*)begin
//if (out12<0)
//    judge12=1;
//else
//    judge12=0;
//end
//
//always@(*)begin
//if (out13<0)
//    judge13=1;
//else
//    judge13=0;
//end
//
//always@(*)begin
//if (out14<0)
//    judge14=1;
//else
//    judge14=0;
//end
///////根據相減後的最高位元判斷操作動作////////////
always@(*)begin
if (out0[14]==0)
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
    judge3=1;
else
    judge3=0;
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
//if (out7[13]==0)
//    judge7=1;
//else
//    judge7=0;
//end
//
//always@(*)begin
//if (out8[13]==0)
//    judge8=1;
//else
//    judge8=0;
//end
//
//always@(*)begin
//if (out9[13]==0)
//    judge9=1;
//else
//    judge9=0;
//end
//
//always@(*)begin
//if (out10[13]==0)
//    judge10=1;
//else
//    judge10=0;
//end
//
//always@(*)begin
//if (out11[13]==0)
//    judge11=1;
//else
//    judge11=0;
//end
//
//always@(*)begin
//if (out12[13]==0)
//    judge12=1;
//else
//    judge12=0;
//end
//
//always@(*)begin
//if (out13[13]==0)
//    judge13=1;
//else
//    judge13=0;
//end
//
//always@(*)begin
//if (out14[13]==0)
//    judge14=1;
//else
//    judge14=0;
//end

//always@(*)begin
//if (out15<0)
//    judge15=1;
//else
//    judge15=0;
//end
///////根據操作動作選擇輸出////////////////
always@(*)begin
if (judge0==1)
    Cw=3'd0;
else if (judge1==1)
    Cw=3'd1;
else if (judge2==1)
    Cw=3'd2;
else if (judge3==1)
    Cw=3'd3;
else if (judge4==1)
    Cw=3'd4;
else if (judge5==1)
    Cw=3'd5;
else if (judge6==1)
    Cw=3'd6;
//else if (judge7==1)
//    Cw=4'd7;
//else if (judge8==1)
//    Cw=4'd8;
//else if (judge9==1)
//    Cw=4'd9;
//else if (judge10==1)
//    Cw=4'd10;
//else if (judge11==1)
//    Cw=4'd11;
//else if (judge12==1)
//    Cw=4'd12;
//else if (judge13==1)
//    Cw=4'd13;
//else if (judge14==1)
//    Cw=4'd14;
else
	if(FMOD==0)
		Cw=3'd3;
	else
		Cw=3'd7; 
end
///////根據操作動作選擇輸出////////////////
endmodule
