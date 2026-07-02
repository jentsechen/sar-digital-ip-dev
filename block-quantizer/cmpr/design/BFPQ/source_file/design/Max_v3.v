`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:23:48 08/27/2018 
// Design Name: 
// Module Name:    Max 
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
module Max_v3(InputI1, InputQ1, InputI2, InputQ2, InputI3, InputQ3, InputI4, InputQ4, clk, rst, Enable, counter, MaxValue_dff
    );
input clk, rst, Enable;
//input signed[13:0] InputI, InputQ;//S2.11
input [12:0] InputI1, InputQ1, InputI2, InputQ2, InputI3, InputQ3, InputI4, InputQ4;//2.11
input [2:0] counter;
reg [2:0] counter_DFF, counter_DFF2;
output reg [12:0]MaxValue_dff;//2.11
reg [12:0]  MaxValue_change, /*MaxValue_dff,*/ MaxValue_change_DFF;
reg [12:0]  out1, out2, out3, out4, out1_DFF, out2_DFF, out3_DFF, out4_DFF, out5, out6, out7, out, out_DFF;
reg p1, p2, p3, p4, p5, p6, p7, p8;
reg signed[13:0] judge8;
wire signed[13:0] judge1, judge2, judge3, judge4, judge5, judge6, judge7;
//getmax_clk GM1(InputI, InputQ, out, clk, rst);
//getmax GM2(MaxValue_change, out, MaxValue_change2, clk, rst);
//always @(*) begin
//  if (InputI[13] == 1'b1) begin
//    InputI_ans = -InputI;
//  end
//  else begin
//    InputI_ans = InputI;
//  end
//end
//
//always @(*) begin
//  if (InputQ[13] == 1'b1) begin
//    InputQ_ans = -InputQ;
//  end
//  else begin
//    InputQ_ans = InputQ;
//  end
//end

//assign judge=InputI_ans-InputQ_ans;

/////第一層///////I軸Q軸相減//////////
assign judge1=InputI1-InputQ1;
assign judge2=InputI2-InputQ2;
assign judge3=InputI3-InputQ3;
assign judge4=InputI4-InputQ4;
/////第一層///////I軸Q軸相減//////////

/////第一層///////根據相減後的最高位元判斷操作動作////////////
always @(*) begin
  if (judge1[13] == 1'b1) begin
    p1=1;
  end
  else begin
    p1=0;
  end
end

always @(*) begin
  if (judge2[13] == 1'b1) begin
    p2=1;
  end
  else begin
    p2=0;
  end
end

always @(*) begin
  if (judge3[13] == 1'b1) begin
    p3=1;
  end
  else begin
    p3=0;
  end
end

always @(*) begin
  if (judge4[13] == 1'b1) begin
    p4=1;
  end
  else begin
    p4=0;
  end
end
/////第一層///////根據相減後的最高位元判斷操作動作////////////

/////第一層///////根據操作動作選擇輸出////////////////
always@(*) begin
if (p1==0) begin	
      out1=InputI1;
   end
   else begin
      out1=InputQ1;
   end
end

always@(*) begin
if (p2==0) begin	
      out2=InputI2;
   end
   else begin
      out2=InputQ2;
   end
end

always@(*) begin
if (p3==0) begin	
      out3=InputI3;
   end
   else begin
      out3=InputQ3;
   end
end

always@(*) begin
if (p4==0) begin	
      out4=InputI4;
   end
   else begin
      out4=InputQ4;
   end
end
////第一層////////根據操作動作選擇輸出////////////////

////////////Pipeline///////////////////
always@(posedge clk or posedge rst)
if(rst)
	out1_DFF<=0;
else if (Enable)
	out1_DFF<=out1;
else
	out1_DFF<=out1_DFF;
	
always@(posedge clk or posedge rst)
if(rst)
	out2_DFF<=0;
else if (Enable)
	out2_DFF<=out2;
else
	out2_DFF<=out2_DFF;
	
always@(posedge clk or posedge rst)
if(rst)
	out3_DFF<=0;
else if (Enable)
	out3_DFF<=out3;
else
	out3_DFF<=out3_DFF;
	
always@(posedge clk or posedge rst)
if(rst)
	out4_DFF<=0;
else if (Enable)
	out4_DFF<=out4;
else
	out4_DFF<=out4_DFF;
////////////Pipeline///////////////////

/////第二層///////I軸Q軸相減//////////
assign judge5=out1_DFF-out2_DFF;
assign judge6=out3_DFF-out4_DFF;
/////第二層///////I軸Q軸相減//////////

/////第二層////////根據相減後的最高位元判斷操作動作////
always @(*) begin
  if (judge5[13] == 1'b1) begin
    p5=1;
  end
  else begin
    p5=0;
  end
end

always @(*) begin
  if (judge6[13] == 1'b1) begin
    p6=1;
  end
  else begin
    p6=0;
  end
end
/////第二層////////根據相減後的最高位元判斷操作動作////

/////第二層////////根據操作動作選擇輸出////////////////
always@(*) begin
if (p5==0) begin	
      out5=out1_DFF;
   end
   else begin
      out5=out2_DFF;
   end
end

always@(*) begin
if (p6==0) begin	
      out6=out3_DFF;
   end
   else begin
      out6=out4_DFF;
   end
end
/////第二層////////根據操作動作選擇輸出////////////////

/////第三層///////I軸Q軸相減//////////
assign judge7=out5-out6;
/////第三層///////I軸Q軸相減//////////

/////第三層////////根據相減後的最高位元判斷操作動作////
always @(*) begin
  if (judge7[13] == 1'b1) begin
    p7=1;
  end
  else begin
    p7=0;
  end
end
/////第三層////////根據相減後的最高位元判斷操作動作////

/////第三層////////根據操作動作選擇輸出////////////////
always@(*) begin
if (p7==0) begin	
      out=out5;
   end
   else begin
      out=out6;
   end
end
/////第三層////////根據操作動作選擇輸出////////////////

////////////Pipeline///////////////////
always@(posedge clk or posedge rst)
if(rst) begin
	counter_DFF<=0;
	counter_DFF2<=0;
	end
else if (Enable) begin
	counter_DFF<=counter;
	counter_DFF2<=counter_DFF;
	end
else begin
	counter_DFF<=counter_DFF;
	counter_DFF2<=counter_DFF2;
	end

always@(posedge clk or posedge rst)
if(rst)
	out_DFF<=0;
else if (Enable)
	out_DFF<=out;
else
	out_DFF<=out_DFF;
////////////Pipeline///////////////////

///////////利用counter判斷何時要將MaxValue_change_DFF歸0///////
always@(*)begin
if (counter_DFF2==1)
	judge8=13'd0-out_DFF;
else
	judge8=MaxValue_change_DFF-out_DFF;
end
//assign judge2=MaxValue_change-out;
///////////利用counter判斷何時要將MaxValue_change_DFF歸0///////

/////////////根據相減後的最高位元判斷操作動作////
always @(*) begin
  if (judge8[13] == 1'b1) begin
    p8=1;
  end
  else begin
    p8=0;
  end
end
/////////////根據相減後的最高位元判斷操作動作////

//
//always @(*) begin
//  if (p2==0) begin
//    MaxValue_change=MaxValue_change_dff;
//  end
//  else begin
//    MaxValue_change=out;
//  end
//end

//always@(posedge clk or posedge rst)begin
//if (rst==1)begin
//	MaxValue_change_dff<=0;
//
//	end
//else begin
//	MaxValue_change_dff<=MaxValue_change;
//
//	end
//end
/////////////根據操作動作選擇輸出////////////////
always@(*)begin
	if (p8==0) begin
	   MaxValue_change=MaxValue_change_DFF;
	end
   else begin
      MaxValue_change=out_DFF;
   end
end
/////////////根據操作動作選擇輸出////////////////

	
always@(posedge clk or posedge rst)begin
if (rst==1)begin
	MaxValue_change_DFF<=0;
	end
else if (Enable)
	MaxValue_change_DFF<=MaxValue_change;
else
   MaxValue_change_DFF<=MaxValue_change_DFF;
end	
///////////////////////////////////

//
//always@(*)begin
////if (counter==5'd1)
////	MaxValue_change=0;
////else
//	MaxValue_change=MaxValue_change2;
//end

//always@(*)begin//**************************
//if (counter_DFF==5'd0)
//	MaxValue=MaxValue_change;
//else
//	MaxValue=MaxValue_dff;
//end

//always@(posedge clk or posedge rst)begin
//if (rst==1)begin
//	MaxValue_change<=0;
//	end
//else if(counter==5'd31)
//	MaxValue_change<=0;
//else begin
//	MaxValue_change<=MaxValue_change2;
//	end
//end

//////////根據counter判斷何時改變輸出或是保留原值////////
always@(posedge clk or posedge rst)begin
if (rst==1)begin
	MaxValue_dff<=0;

	end
else if (Enable)
	if (counter_DFF2==5'd0)
		MaxValue_dff<=MaxValue_change;
	else
		MaxValue_dff<=MaxValue_dff;
//	MaxValue_dff<=MaxValue;
else begin
	MaxValue_dff<=MaxValue_dff;

	end
end
//////////根據counter判斷何時改變輸出或是保留原值////////

endmodule








