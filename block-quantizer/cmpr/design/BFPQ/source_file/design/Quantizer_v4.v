`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:24:16 08/31/2018 
// Design Name: 
// Module Name:    Quantizer 
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
module Quantizer_v4(clk, rst, Enable, in/*, BMOD*/, MMOD, Ce, out
    );
input clk, rst, Enable;
input [2:0] Ce;
//input [1:0] BMOD;
input [2:0] MMOD;
input [17:0] in;//3.15
//input [14:0] shiftOut0, shiftOut1, shiftOut2, shiftOut3, shiftOut4, shiftOut5, shiftOut6, shiftOut7, shiftOut8, shiftOut9, shiftOut10, shiftOut11, shiftOut12, shiftOut13, 
//					shiftOut14, shiftOut15, shiftOut16, shiftOut17, shiftOut18, shiftOut19, shiftOut20, shiftOut21, shiftOut22, shiftOut23, shiftOut24, shiftOut25, shiftOut26, shiftOut27, shiftOut28, 
//					shiftOut29, shiftOut30, shiftOut31, shiftOut32, shiftOut33, shiftOut34, shiftOut35, shiftOut36, shiftOut37, shiftOut38, shiftOut39, shiftOut40, shiftOut41, shiftOut42, shiftOut43, 
//					shiftOut44, shiftOut45, shiftOut46, shiftOut47, shiftOut48, shiftOut49, shiftOut50, shiftOut51, shiftOut52, shiftOut53, shiftOut54, shiftOut55, shiftOut56, shiftOut57, shiftOut58, 
//					shiftOut59, shiftOut60, shiftOut61, shiftOut62, shiftOut63, shiftOut64, shiftOut65, shiftOut66, shiftOut67, shiftOut68, shiftOut69, shiftOut70, shiftOut71, shiftOut72, shiftOut73, 
//					shiftOut74, shiftOut75, shiftOut76, shiftOut77, shiftOut78, shiftOut79, shiftOut80, shiftOut81, shiftOut82, shiftOut83, shiftOut84, shiftOut85, shiftOut86, shiftOut87, shiftOut88, 
//					shiftOut89, shiftOut90, shiftOut91, shiftOut92, shiftOut93, shiftOut94, shiftOut95, shiftOut96, shiftOut97, shiftOut98, shiftOut99, shiftOut100, shiftOut101, shiftOut102, shiftOut103,
//					shiftOut104, shiftOut105, shiftOut106, shiftOut107, shiftOut108, shiftOut109, shiftOut110, shiftOut111, shiftOut112, shiftOut113, shiftOut114, shiftOut115, shiftOut116, shiftOut117, 
//					shiftOut118, shiftOut119, shiftOut120, shiftOut121, shiftOut122, shiftOut123, shiftOut124, shiftOut125, shiftOut126, shiftOut127;
output reg[6:0] out;


reg [11:0] bound, bound1, bound2, bound3, bound4, bound5, bound6;//, buffer0, buffer1, buffer2, buffer3, buffer4, buffer5;
reg [17:0] bound_shift, bound1_shift, bound2_shift, bound3_shift, bound4_shift, bound5_shift, bound6_shift;//, buffer0, buffer1, buffer2, buffer3, buffer4, buffer5;3.15


reg signed [18:0] com_value0, com_value1, com_value2, com_value3, com_value4, com_value5, com_value6;
reg judge0, judge1, judge2, judge3, judge4, judge5, judge6;
reg index;
reg index_DFF;
reg [1:0] index1;
reg [1:0] index1_DFF;
reg [2:0] index2;
reg [2:0] index2_DFF;
reg [3:0] index3;
reg [3:0] index3_DFF;
reg [4:0] index4;
reg [4:0] index4_DFF;
reg [5:0] index5;
reg [5:0] index5_DFF;
reg [6:0] index6;
//reg [5:0] counter;

//reg [6:0] index_add, index_add1, index_add2, index_add3, index_add4, index_add5;

//reg [6:0] index_DFF, index1_DFF, index2_DFF, index3_DFF, index4_DFF, index5_DFF;
//
//always@(posedge clk or posedge rst)begin
//if (rst)begin
//	counter<=0;
//	end
//else begin
//	if (counter==6'd33)
//		counter<=counter;
//	else
//		counter<=counter+1;
//	end
//end

wire [11:0]XThreshold0; 
wire [11:0]XThreshold1[0:2];
wire [11:0]XThreshold2[0:6]; 
wire [11:0]XThreshold3[0:30];
wire [11:0]XThreshold4[0:126]; 


assign  XThreshold0=12'b001110011110; 


assign  XThreshold1[0]=12'b001000110100; 
assign  XThreshold1[1]=12'b010001101001; 
assign  XThreshold1[2]=12'b011010011110;

assign  XThreshold2[0]=12'b000100110000; 
assign  XThreshold2[1]=12'b001001100000; 
assign  XThreshold2[2]=12'b001110010000; 
assign  XThreshold2[3]=12'b010011000000; 
assign  XThreshold2[4]=12'b010111110000; 
assign  XThreshold2[5]=12'b011100100000; 
assign  XThreshold2[6]=12'b100001010000;

assign  XThreshold3[0]=12'b000001010110; 
assign  XThreshold3[1]=12'b000010101101; 
assign  XThreshold3[2]=12'b000100000100; 
assign  XThreshold3[3]=12'b000101011011; 
assign  XThreshold3[4]=12'b000110110010; 
assign  XThreshold3[5]=12'b001000001001; 
assign  XThreshold3[6]=12'b001001100000; 
assign  XThreshold3[7]=12'b001010110111; 
assign  XThreshold3[8]=12'b001100001110; 
assign  XThreshold3[9]=12'b001101100100; 
assign  XThreshold3[10]=12'b001110111011; 
assign  XThreshold3[11]=12'b010000010010; 
assign  XThreshold3[12]=12'b010001101001; 
assign  XThreshold3[13]=12'b010011000000; 
assign  XThreshold3[14]=12'b010100010111; 
assign  XThreshold3[15]=12'b010101101110; 
assign  XThreshold3[16]=12'b010111000101; 
assign  XThreshold3[17]=12'b011000011100; 
assign  XThreshold3[18]=12'b011001110010; 
assign  XThreshold3[19]=12'b011011001001; 
assign  XThreshold3[20]=12'b011100100000; 
assign  XThreshold3[21]=12'b011101110111; 
assign  XThreshold3[22]=12'b011111001110; 
assign  XThreshold3[23]=12'b100000100101; 
assign  XThreshold3[24]=12'b100001111100; 
assign  XThreshold3[25]=12'b100011010011; 
assign  XThreshold3[26]=12'b100100101010; 
assign  XThreshold3[27]=12'b100110000000; 
assign  XThreshold3[28]=12'b100111010111; 
assign  XThreshold3[29]=12'b101000101110; 
assign  XThreshold3[30]=12'b101010000101; 

assign  XThreshold4[0]=12'b000000010110; 
assign  XThreshold4[1]=12'b000000101100; 
assign  XThreshold4[2]=12'b000001000011; 
assign  XThreshold4[3]=12'b000001011001; 
assign  XThreshold4[4]=12'b000001110000; 
assign  XThreshold4[5]=12'b000010000110; 
assign  XThreshold4[6]=12'b000010011101; 
assign  XThreshold4[7]=12'b000010110011; 
assign  XThreshold4[8]=12'b000011001010; 
assign  XThreshold4[9]=12'b000011100000; 
assign  XThreshold4[10]=12'b000011110110; 
assign  XThreshold4[11]=12'b000100001101; 
assign  XThreshold4[12]=12'b000100100011; 
assign  XThreshold4[13]=12'b000100111010; 
assign  XThreshold4[14]=12'b000101010000; 
assign  XThreshold4[15]=12'b000101100111; 
assign  XThreshold4[16]=12'b000101111101; 
assign  XThreshold4[17]=12'b000110010100; 
assign  XThreshold4[18]=12'b000110101010; 
assign  XThreshold4[19]=12'b000111000000; 
assign  XThreshold4[20]=12'b000111010111; 
assign  XThreshold4[21]=12'b000111101101; 
assign  XThreshold4[22]=12'b001000000100; 
assign  XThreshold4[23]=12'b001000011010; 
assign  XThreshold4[24]=12'b001000110001; 
assign  XThreshold4[25]=12'b001001000111; 
assign  XThreshold4[26]=12'b001001011110; 
assign  XThreshold4[27]=12'b001001110100; 
assign  XThreshold4[28]=12'b001010001010; 
assign  XThreshold4[29]=12'b001010100001; 
assign  XThreshold4[30]=12'b001010110111; 
assign  XThreshold4[31]=12'b001011001110; 
assign  XThreshold4[32]=12'b001011100100; 
assign  XThreshold4[33]=12'b001011111011; 
assign  XThreshold4[34]=12'b001100010001; 
assign  XThreshold4[35]=12'b001100101000; 
assign  XThreshold4[36]=12'b001100111110; 
assign  XThreshold4[37]=12'b001101010100; 
assign  XThreshold4[38]=12'b001101101011; 
assign  XThreshold4[39]=12'b001110000001; 
assign  XThreshold4[40]=12'b001110011000; 
assign  XThreshold4[41]=12'b001110101110; 
assign  XThreshold4[42]=12'b001111000101; 
assign  XThreshold4[43]=12'b001111011011; 
assign  XThreshold4[44]=12'b001111110010; 
assign  XThreshold4[45]=12'b010000001000; 
assign  XThreshold4[46]=12'b010000011110; 
assign  XThreshold4[47]=12'b010000110101; 
assign  XThreshold4[48]=12'b010001001011; 
assign  XThreshold4[49]=12'b010001100010; 
assign  XThreshold4[50]=12'b010001111000; 
assign  XThreshold4[51]=12'b010010001111; 
assign  XThreshold4[52]=12'b010010100101; 
assign  XThreshold4[53]=12'b010010111100; 
assign  XThreshold4[54]=12'b010011010010; 
assign  XThreshold4[55]=12'b010011101000; 
assign  XThreshold4[56]=12'b010011111111; 
assign  XThreshold4[57]=12'b010100010101; 
assign  XThreshold4[58]=12'b010100101100; 
assign  XThreshold4[59]=12'b010101000010; 
assign  XThreshold4[60]=12'b010101011001; 
assign  XThreshold4[61]=12'b010101101111; 
assign  XThreshold4[62]=12'b010110000110; 
assign  XThreshold4[63]=12'b010110011100; 
assign  XThreshold4[64]=12'b010110110011; 
assign  XThreshold4[65]=12'b010111001001; 
assign  XThreshold4[66]=12'b010111011111; 
assign  XThreshold4[67]=12'b010111110110; 
assign  XThreshold4[68]=12'b011000001100; 
assign  XThreshold4[69]=12'b011000100011; 
assign  XThreshold4[70]=12'b011000111001; 
assign  XThreshold4[71]=12'b011001010000; 
assign  XThreshold4[72]=12'b011001100110; 
assign  XThreshold4[73]=12'b011001111101; 
assign  XThreshold4[74]=12'b011010010011; 
assign  XThreshold4[75]=12'b011010101001; 
assign  XThreshold4[76]=12'b011011000000; 
assign  XThreshold4[77]=12'b011011010110; 
assign  XThreshold4[78]=12'b011011101101; 
assign  XThreshold4[79]=12'b011100000011; 
assign  XThreshold4[80]=12'b011100011010; 
assign  XThreshold4[81]=12'b011100110000; 
assign  XThreshold4[82]=12'b011101000111; 
assign  XThreshold4[83]=12'b011101011101; 
assign  XThreshold4[84]=12'b011101110011; 
assign  XThreshold4[85]=12'b011110001010; 
assign  XThreshold4[86]=12'b011110100000; 
assign  XThreshold4[87]=12'b011110110111; 
assign  XThreshold4[88]=12'b011111001101; 
assign  XThreshold4[89]=12'b011111100100; 
assign  XThreshold4[90]=12'b011111111010; 
assign  XThreshold4[91]=12'b100000010001; 
assign  XThreshold4[92]=12'b100000100111; 
assign  XThreshold4[93]=12'b100000111101; 
assign  XThreshold4[94]=12'b100001010100; 
assign  XThreshold4[95]=12'b100001101010; 
assign  XThreshold4[96]=12'b100010000001; 
assign  XThreshold4[97]=12'b100010010111; 
assign  XThreshold4[98]=12'b100010101110; 
assign  XThreshold4[99]=12'b100011000100; 
assign  XThreshold4[100]=12'b100011011011; 
assign  XThreshold4[101]=12'b100011110001; 
assign  XThreshold4[102]=12'b100100000111; 
assign  XThreshold4[103]=12'b100100011110; 
assign  XThreshold4[104]=12'b100100110100; 
assign  XThreshold4[105]=12'b100101001011; 
assign  XThreshold4[106]=12'b100101100001; 
assign  XThreshold4[107]=12'b100101111000; 
assign  XThreshold4[108]=12'b100110001110; 
assign  XThreshold4[109]=12'b100110100101; 
assign  XThreshold4[110]=12'b100110111011; 
assign  XThreshold4[111]=12'b100111010001; 
assign  XThreshold4[112]=12'b100111101000; 
assign  XThreshold4[113]=12'b100111111110; 
assign  XThreshold4[114]=12'b101000010101; 
assign  XThreshold4[115]=12'b101000101011; 
assign  XThreshold4[116]=12'b101001000010; 
assign  XThreshold4[117]=12'b101001011000; 
assign  XThreshold4[118]=12'b101001101111; 
assign  XThreshold4[119]=12'b101010000101; 
assign  XThreshold4[120]=12'b101010011100; 
assign  XThreshold4[121]=12'b101010110010; 
assign  XThreshold4[122]=12'b101011001000; 
assign  XThreshold4[123]=12'b101011011111; 
assign  XThreshold4[124]=12'b101011110101; 
assign  XThreshold4[125]=12'b101100001100; 
assign  XThreshold4[126]=12'b101100100010; 


//always@(posedge clk or posedge rst)begin
//	if(rst==1)
//		counter<=0;
//	else if(BMOD==2'd0 && counter==6'd9)
//		counter<=counter;
//	else if(BMOD==2'd1 && counter==6'd17)
//		counter<=counter;
//	else if(BMOD==2'd2 && counter==6'd33)
//		counter<=counter;
//	else
//		counter<=counter+1;	
//end
///////�N�t�������ƶ���쥿�T���k����/////////
reg [2:0] Ce_right_shift;
always@(*) begin
	case(Ce)
		3'd0:Ce_right_shift=3'd4;
		3'd1:Ce_right_shift=3'd3;
		3'd2:Ce_right_shift=3'd2;
		3'd3:Ce_right_shift=3'd1;
		default: Ce_right_shift=3'd0;
	endcase
end
///////�N�t�������ƶ���쥿�T���k����/////////
///////Pipeline///////////////////
reg [2:0] Ce_DFF, Ce_DFF2, Ce_DFF3, Ce_DFF4, Ce_DFF5, Ce_DFF6;
reg [2:0] Ce_right_shift_DFF, Ce_right_shift_DFF2, Ce_right_shift_DFF3, Ce_right_shift_DFF4, Ce_right_shift_DFF5, Ce_right_shift_DFF6;
always@(posedge clk or posedge rst)begin
if (rst) begin
	Ce_right_shift_DFF<=0;
	Ce_right_shift_DFF2<=0;
	Ce_right_shift_DFF3<=0; 	
	Ce_right_shift_DFF4<=0;
	Ce_right_shift_DFF5<=0; 
	Ce_right_shift_DFF6<=0;
	end
else if(Enable) begin
	Ce_right_shift_DFF<=Ce_right_shift;
	Ce_right_shift_DFF2<=Ce_right_shift_DFF;
	Ce_right_shift_DFF3<=Ce_right_shift_DFF2;
	Ce_right_shift_DFF4<=Ce_right_shift_DFF3;
	Ce_right_shift_DFF5<=Ce_right_shift_DFF4;
	Ce_right_shift_DFF6<=Ce_right_shift_DFF5;
	end
else begin
	Ce_right_shift_DFF<=Ce_right_shift_DFF;
	Ce_right_shift_DFF2<=Ce_right_shift_DFF2;
	Ce_right_shift_DFF3<=Ce_right_shift_DFF3;
	Ce_right_shift_DFF4<=Ce_right_shift_DFF4;
	Ce_right_shift_DFF5<=Ce_right_shift_DFF5;
	Ce_right_shift_DFF6<=Ce_right_shift_DFF6;
	end
	end
	
always@(posedge clk or posedge rst)begin
if (rst) begin
	Ce_DFF<=0;
	Ce_DFF2<=0;
	Ce_DFF3<=0; 	
	Ce_DFF4<=0;
	Ce_DFF5<=0;
	Ce_DFF6<=0; 
	end
else if(Enable)begin
	Ce_DFF<=Ce;
	Ce_DFF2<=Ce_DFF;
	Ce_DFF3<=Ce_DFF2;
	Ce_DFF4<=Ce_DFF3;
	Ce_DFF5<=Ce_DFF4;
	Ce_DFF6<=Ce_DFF5;
	end
else begin
	Ce_DFF<=Ce_DFF;
	Ce_DFF2<=Ce_DFF2;
	Ce_DFF3<=Ce_DFF3;
	Ce_DFF4<=Ce_DFF4;
	Ce_DFF5<=Ce_DFF5;
	Ce_DFF6<=Ce_DFF6;
	end
	end
	
reg [17:0] in_DFF1, in_DFF2, in_DFF3, in_DFF4, in_DFF5, in_DFF6;
always@(posedge clk or posedge rst)
if(rst) begin
	in_DFF1<=0;
	in_DFF2<=0;
	in_DFF3<=0;
	in_DFF4<=0;
	in_DFF5<=0;
	in_DFF6<=0;
	end
else if (Enable)begin
	in_DFF1<=in;
	in_DFF2<=in_DFF1;
	in_DFF3<=in_DFF2;
	in_DFF4<=in_DFF3;
	in_DFF5<=in_DFF4;
	in_DFF6<=in_DFF5;
	end
else begin
	in_DFF1<=in_DFF1;
	in_DFF2<=in_DFF2;
	in_DFF3<=in_DFF3;
	in_DFF4<=in_DFF4;
	in_DFF5<=in_DFF5;
	in_DFF6<=in_DFF6;
	end
///////Pipeline///////////////////

///////�ھ�MMOD��ܤ��������////////
always@(*)begin
	case(MMOD)
		3'd0:bound=XThreshold0;
		3'd1:bound=XThreshold1[1];
		3'd2:bound=XThreshold2[3];  
		3'd3:bound=XThreshold3[15]; 
		3'd4:bound=XThreshold4[63]; 
		default:bound=0;
	endcase
end
///////�ھ�MMOD��ܤ��������////////

/////////////�N��ɥ����Υk���ܸ�exponent///////////////
always@(*)begin
	if(Ce[2]==0) 
		bound_shift={bound,3'b000}>>Ce_right_shift;
	else
		bound_shift={bound,3'b000}<<Ce[1:0];  
end
/////////////�N��ɥ����Υk���ܸ�exponent///////////////

///////�ھ�MMOD��index�U�@�����////////
always@(*)begin
case(MMOD)
		3'd1:case(index_DFF)
					1'b0:bound1=XThreshold1[0];
					1'b1:bound1=XThreshold1[2];
			  endcase
		3'd2:case(index_DFF)
					1'b0:bound1=XThreshold2[1];  
					1'b1:bound1=XThreshold2[5];  
			  endcase 
		3'd3:case(index_DFF)
					1'b0:bound1=XThreshold3[7];  
					1'b1:bound1=XThreshold3[23];  
			  endcase
		3'd4:case(index_DFF)
					1'b0:bound1=XThreshold4[31];
					1'b1:bound1=XThreshold4[95];
			  endcase 
		default:bound1=0;
	endcase

end

always@(*)begin
	if(Ce_DFF[2]==0) 
		bound1_shift={bound1,3'b000}>>Ce_right_shift_DFF;
	else
		bound1_shift={bound1,3'b000}<<Ce_DFF[1:0];  
end

always@(*)begin
case(MMOD)
		3'd2:case(index1_DFF)
					2'b00:bound2=XThreshold2[0]; 
					2'b01:bound2=XThreshold2[2];  
					2'b10:bound2=XThreshold2[4];  
					2'b11:bound2=XThreshold2[6];  
			  endcase
		3'd3:case(index1_DFF)
					2'b00:bound2=XThreshold3[3];  
					2'b01:bound2=XThreshold3[11];   
					2'b10:bound2=XThreshold3[19];    
					2'b11:bound2=XThreshold3[27]; 
			  endcase
		3'd4:case(index1_DFF)
					2'b00:bound2=XThreshold4[15];
					2'b01:bound2=XThreshold4[47];
					2'b10:bound2=XThreshold4[79]; 
					2'b11:bound2=XThreshold4[111];   
			  endcase
		default:bound2=0;
	
endcase
end

always@(*)begin
	if(Ce_DFF2[2]==0) 
		bound2_shift={bound2,3'b000}>>Ce_right_shift_DFF2;
	else
		bound2_shift={bound2,3'b000}<<Ce_DFF2[1:0];  
end


always@(*)begin
case(MMOD)
		3'd3:case(index2_DFF)
					3'b000:bound3=XThreshold3[1]; 
					3'b001:bound3=XThreshold3[5];   
					3'b010:bound3=XThreshold3[9];   
					3'b011:bound3=XThreshold3[13];  
					3'b100:bound3=XThreshold3[17];  
					3'b101:bound3=XThreshold3[21];  
					3'b110:bound3=XThreshold3[25];  
					3'b111:bound3=XThreshold3[29];  
			  endcase
		3'd4:case(index2_DFF)
					3'b000:bound3=XThreshold4[7]; 
					3'b001:bound3=XThreshold4[23];   
					3'b010:bound3=XThreshold4[39];    
					3'b011:bound3=XThreshold4[55]; 
					3'b100:bound3=XThreshold4[71];  
					3'b101:bound3=XThreshold4[87];  
					3'b110:bound3=XThreshold4[103]; 
					3'b111:bound3=XThreshold4[119];  
			  endcase
		default:bound3=0;

endcase
end

always@(*)begin
	if(Ce_DFF3[2]==0) 
		bound3_shift={bound3,3'b000}>>Ce_right_shift_DFF3;
	else
		bound3_shift={bound3,3'b000}<<Ce_DFF3[1:0];  
end



always@(*)begin
case(MMOD)
		3'd3:case(index3_DFF)
					4'b0000:bound4=XThreshold3[0];  
					4'b0001:bound4=XThreshold3[2];  
					4'b0010:bound4=XThreshold3[4];    
					4'b0011:bound4=XThreshold3[6];  
					4'b0100:bound4=XThreshold3[8];   
					4'b0101:bound4=XThreshold3[10];  
					4'b0110:bound4=XThreshold3[12];  
					4'b0111:bound4=XThreshold3[14];  
					4'b1000:bound4=XThreshold3[16];  
					4'b1001:bound4=XThreshold3[18];   
					4'b1010:bound4=XThreshold3[20];   
					4'b1011:bound4=XThreshold3[22];  
					4'b1100:bound4=XThreshold3[24];  
					4'b1101:bound4=XThreshold3[26];  
					4'b1110:bound4=XThreshold3[28];  
					4'b1111:bound4=XThreshold3[30];  
			  endcase
		3'd4:case(index3_DFF)
					4'b0000:bound4=XThreshold4[3];   
					4'b0001:bound4=XThreshold4[11];   
					4'b0010:bound4=XThreshold4[19];   
					4'b0011:bound4=XThreshold4[27];   
					4'b0100:bound4=XThreshold4[35];   
					4'b0101:bound4=XThreshold4[43];   
					4'b0110:bound4=XThreshold4[51];   
					4'b0111:bound4=XThreshold4[59];   
					4'b1000:bound4=XThreshold4[67];   
					4'b1001:bound4=XThreshold4[75];   
					4'b1010:bound4=XThreshold4[83];   
					4'b1011:bound4=XThreshold4[91];   
					4'b1100:bound4=XThreshold4[99];   
					4'b1101:bound4=XThreshold4[107];   
					4'b1110:bound4=XThreshold4[115];   
					4'b1111:bound4=XThreshold4[123]; 
			  endcase
		default:bound4=0;

endcase
end

always@(*)begin
	if(Ce_DFF4[2]==0) 
		bound4_shift={bound4,3'b000}>>Ce_right_shift_DFF4;
	else
		bound4_shift={bound4,3'b000}<<Ce_DFF4[1:0];  
end


always@(*)begin
case(MMOD)
		3'd4:case(index4_DFF)
					5'b00000:bound5=XThreshold4[1];   
					5'b00001:bound5=XThreshold4[5];   
					5'b00010:bound5=XThreshold4[9];   
					5'b00011:bound5=XThreshold4[13];   
					5'b00100:bound5=XThreshold4[17];   
					5'b00101:bound5=XThreshold4[21];   
					5'b00110:bound5=XThreshold4[25];   
					5'b00111:bound5=XThreshold4[29];   
					5'b01000:bound5=XThreshold4[33];   
					5'b01001:bound5=XThreshold4[37];   
					5'b01010:bound5=XThreshold4[41];   
					5'b01011:bound5=XThreshold4[45];   
					5'b01100:bound5=XThreshold4[49];   
					5'b01101:bound5=XThreshold4[53];   
					5'b01110:bound5=XThreshold4[57];   
					5'b01111:bound5=XThreshold4[61];
					5'b10000:bound5=XThreshold4[65];   
					5'b10001:bound5=XThreshold4[69];   
					5'b10010:bound5=XThreshold4[73];   
					5'b10011:bound5=XThreshold4[77];   
					5'b10100:bound5=XThreshold4[81];   
					5'b10101:bound5=XThreshold4[85];   
					5'b10110:bound5=XThreshold4[89];   
					5'b10111:bound5=XThreshold4[93];   
					5'b11000:bound5=XThreshold4[97];   
					5'b11001:bound5=XThreshold4[101];   
					5'b11010:bound5=XThreshold4[105];   
					5'b11011:bound5=XThreshold4[109];   
					5'b11100:bound5=XThreshold4[113];   
					5'b11101:bound5=XThreshold4[117];   
					5'b11110:bound5=XThreshold4[121];   
					5'b11111:bound5=XThreshold4[125];    
			  endcase
		default:bound5=0;

endcase
end

always@(*)begin
	if(Ce_DFF5[2]==0) 
		bound5_shift={bound5,3'b000}>>Ce_right_shift_DFF5;
	else
		bound5_shift={bound5,3'b000}<<Ce_DFF5[1:0];  
end


always@(*)begin
case(MMOD)
		3'd4:case(index5_DFF)
					6'd0:bound6=XThreshold4[0];   
					6'd1:bound6=XThreshold4[2];   
					6'd2:bound6=XThreshold4[4];   
					6'd3:bound6=XThreshold4[6];   
					6'd4:bound6=XThreshold4[8];   
					6'd5:bound6=XThreshold4[10];   
					6'd6:bound6=XThreshold4[12];   
					6'd7:bound6=XThreshold4[14];   
					6'd8:bound6=XThreshold4[16];   
					6'd9:bound6=XThreshold4[18];   
					6'd10:bound6=XThreshold4[20];   
					6'd11:bound6=XThreshold4[22];   
					6'd12:bound6=XThreshold4[24];   
					6'd13:bound6=XThreshold4[26];   
					6'd14:bound6=XThreshold4[28];   
					6'd15:bound6=XThreshold4[30];   
					6'd16:bound6=XThreshold4[32];   
					6'd17:bound6=XThreshold4[34];   
					6'd18:bound6=XThreshold4[36];   
					6'd19:bound6=XThreshold4[38];   
					6'd20:bound6=XThreshold4[40];   
					6'd21:bound6=XThreshold4[42];   
					6'd22:bound6=XThreshold4[44];   
					6'd23:bound6=XThreshold4[46];   
					6'd24:bound6=XThreshold4[48];   
					6'd25:bound6=XThreshold4[50];   
					6'd26:bound6=XThreshold4[52];   
					6'd27:bound6=XThreshold4[54];   
					6'd28:bound6=XThreshold4[56];   
					6'd29:bound6=XThreshold4[58];   
					6'd30:bound6=XThreshold4[60];   
					6'd31:bound6=XThreshold4[62];   
					6'd32:bound6=XThreshold4[64];   
					6'd33:bound6=XThreshold4[66];   
					6'd34:bound6=XThreshold4[68];   
					6'd35:bound6=XThreshold4[70];   
					6'd36:bound6=XThreshold4[72];   
					6'd37:bound6=XThreshold4[74];   
					6'd38:bound6=XThreshold4[76];   
					6'd39:bound6=XThreshold4[78];   
					6'd40:bound6=XThreshold4[80];   
					6'd41:bound6=XThreshold4[82];   
					6'd42:bound6=XThreshold4[84];   
					6'd43:bound6=XThreshold4[86];   
					6'd44:bound6=XThreshold4[88];   
					6'd45:bound6=XThreshold4[90];   
					6'd46:bound6=XThreshold4[92];   
					6'd47:bound6=XThreshold4[94];   
					6'd48:bound6=XThreshold4[96];   
					6'd49:bound6=XThreshold4[98];   
					6'd50:bound6=XThreshold4[100];   
					6'd51:bound6=XThreshold4[102];   
					6'd52:bound6=XThreshold4[104];   
					6'd53:bound6=XThreshold4[106];   
					6'd54:bound6=XThreshold4[108];   
					6'd55:bound6=XThreshold4[110];   
					6'd56:bound6=XThreshold4[112];   
					6'd57:bound6=XThreshold4[114];   
					6'd58:bound6=XThreshold4[116];   
					6'd59:bound6=XThreshold4[118];   
					6'd60:bound6=XThreshold4[120];   
					6'd61:bound6=XThreshold4[122];   
					6'd62:bound6=XThreshold4[124];   
					6'd63:bound6=XThreshold4[126];
			  endcase
		default:bound6=0;
	endcase

end

always@(*)begin
	if(Ce_DFF6[2]==0) 
		bound6_shift={bound6,3'b000}>>Ce_right_shift_DFF6;
	else
		bound6_shift={bound6,3'b000}<<Ce_DFF6[1:0];  
end
///////�ھ�MMOD��index�U�@�����////////

//always@(posedge clk or posedge rst)begin
//if (rst)begin
//	buffer0<=0;
//	buffer1<=0;
//	buffer2<=0;
//	buffer3<=0;
//	buffer4<=0;
//	buffer5<=0;
//	end
//else begin
//	buffer0<=in;
//	buffer1<=buffer0;
//	buffer2<=buffer1;
//	buffer3<=buffer2;
//	buffer4<=buffer3;
//	buffer5<=buffer4;
//	end
//end


//assign com_value0=in-bound;
//assign com_value1=buffer0-bound1;
//assign com_value2=buffer1-bound2;
//assign com_value3=buffer2-bound3;
//assign com_value4=buffer3-bound4;
//assign com_value5=buffer4-bound5;
//assign com_value6=buffer5-bound6;


//assign com_value0=in-bound;
//assign com_value1=in-bound1;
//assign com_value2=in-bound2;
//assign com_value3=in-bound3;
//assign com_value4=in-bound4;
//assign com_value5=in-bound5;
//assign com_value6=in-bound6;



	
//reg [14:0] in_test;
//always@(*)
//in_test=in_DFF1;
	
////////////�ھ�MMOD��ܿ�J�T���P��ɬ۴�//////////
always@(*) begin
	case(MMOD)
		3'd0:begin
				com_value0=bound_shift-in;
				com_value1=0;
				com_value2=0;
				com_value3=0;
				com_value4=0;
				com_value5=0;
				com_value6=0;
			  end
		3'd1:begin
				com_value0=bound_shift-in;
				com_value1=bound1_shift-in_DFF1;
				com_value2=0;
				com_value3=0;
				com_value4=0;
				com_value5=0;
				com_value6=0;
			  end
		3'd2:begin
				com_value0=bound_shift-in;
				com_value1=bound1_shift-in_DFF1;
				com_value2=bound2_shift-in_DFF2;
				com_value3=0;
				com_value4=0;
				com_value5=0;
				com_value6=0;
			  end
		3'd3:begin
				com_value0=bound_shift-in;
				com_value1=bound1_shift-in_DFF1;
				com_value2=bound2_shift-in_DFF2;
				com_value3=bound3_shift-in_DFF3;
				com_value4=bound4_shift-in_DFF4;
				com_value5=0;
				com_value6=0;
			  end
		3'd4:begin
				com_value0=bound_shift-in;
				com_value1=bound1_shift-in_DFF1;
				com_value2=bound2_shift-in_DFF2;
				com_value3=bound3_shift-in_DFF3;
				com_value4=bound4_shift-in_DFF4;
				com_value5=bound5_shift-in_DFF5;
				com_value6=bound6_shift-in_DFF6;
			  end
		default:begin
				com_value0=0;
				com_value1=0;
				com_value2=0;
				com_value3=0;
				com_value4=0;
				com_value5=0;
				com_value6=0;
			  end
	endcase
end
////////////�ھ�MMOD��ܿ�J�T���P��ɬ۴�//////////

///////�ھڬ۴�᪺�̰��줸�P�_�ާ@�ʧ@////////////
always@(*)begin
if (com_value0[18]==0)
    judge0=1'b0;
else
    judge0=1'b1;
end

always@(*)begin
if (com_value1[18]==0)
    judge1=1'b0;
else
    judge1=1'b1;
end

always@(*)begin
if (com_value2[18]==0)
    judge2=1'b0;
else
    judge2=1'b1;
end

always@(*)begin
if (com_value3[18]==0)
    judge3=1'b0;
else
    judge3=1'b1;
end

always@(*)begin
if (com_value4[18]==0)
    judge4=1'b0;
else
    judge4=1'b1;
end

always@(*)begin
if (com_value5[18]==0)
    judge5=1'b0;
else
    judge5=1'b1;
end

always@(*)begin
if (com_value6[18]==0)
    judge6=1'b0;
else
    judge6=1'b1;
end
///////�ھڬ۴�᪺�̰��줸�P�_�ާ@�ʧ@////////////

///////�ھڬ۴�᪺�̰��줸�P�_�ާ@�ʧ@////////////
always@(*)begin
//	if (counter>=6'd33) begin
		if (judge0==0) begin
//			index=7'd63-6'd32;
			index=1'b0;
			end
		else begin
//			index=7'd63+6'd32;
			index=1'd1;
			end
//	end
//	else begin
//		index=7'd63;
//		end
end

always@(posedge clk or posedge rst)begin
if (rst)
	index_DFF<=7'd0;
else if (Enable)
	index_DFF<=index;
else
	index_DFF<=index_DFF;
	end

//wire [1:0] index_shift;
//wire index_or1;
//assign index_shift=index<<1'd1;
//assign index_or1=(judge1)?(1'b1):(1'b0);
//or g1(index1, index_shift, index_or1); 

always@(*)begin
	if (judge1==0) begin
		index1={index_DFF,1'b0};
		end
	else begin
		index1={index_DFF,1'b1};
		end
	end

always@(posedge clk or posedge rst)
if (rst)
	index1_DFF<=0;
else if (Enable)
	index1_DFF<=index1;
else
	index1_DFF<=index1_DFF;


always@(*)begin
	if (judge2==0) begin
		index2={index1_DFF,1'b0};
		end
	else begin
		index2={index1_DFF,1'b1};
		end
	end


always@(posedge clk or posedge rst)
if (rst)
	index2_DFF<=0;
else if (Enable)
	index2_DFF<=index2;
else
	index2_DFF<=index2_DFF;


always@(*)begin
	if (judge3==0) begin
		index3={index2_DFF,1'b0};
		end
	else begin
		index3={index2_DFF,1'b1};
		end
	end
	
always@(posedge clk or posedge rst)
if (rst)
	index3_DFF<=0;
else if (Enable)
	index3_DFF<=index3;
else
	index3_DFF<=index3_DFF;


always@(*)begin
	if (judge4==0) begin
		index4={index3_DFF,1'b0};
		end
	else begin
		index4={index3_DFF,1'b1};
		end
	end
	
always@(posedge clk or posedge rst)
if (rst)
	index4_DFF<=0;
else if (Enable)
	index4_DFF<=index4;
else
	index4_DFF<=index4_DFF;


always@(*)begin
	if (judge5==0) begin
		index5={index4_DFF,1'b0};
		end
	else begin
		index5={index4_DFF,1'b1};
		end
	end
	
always@(posedge clk or posedge rst)
if (rst)
	index5_DFF<=7'd0;
else if (Enable)
	index5_DFF<=index5;
else
	index5_DFF<=index5_DFF;


always@(*)begin
	if (judge6==0) begin
		index6={index5_DFF,1'b0};
		end
	else begin
		index6={index5_DFF,1'b1};
		end
	end
///////�ھڬ۴�᪺�̰��줸�P�_�ާ@�ʧ@////////////
// reg index_DFF2, index_DFF3, index_DFF4, index_DFF5, index_DFF6;
// always@(posedge clk or posedge rst)
// if (rst) begin
// 	index_DFF2<=0;
// 	index_DFF3<=0;
// 	index_DFF4<=0;
// 	index_DFF5<=0;
// 	index_DFF6<=0;
// 	end
// else if (Enable) begin
// 	index_DFF2<=index_DFF;
// 	index_DFF3<=index_DFF2;
// 	index_DFF4<=index_DFF3;
// 	index_DFF5<=index_DFF4;
// 	index_DFF6<=index_DFF5;
// 	end
// else begin
// 	index_DFF2<=index_DFF2;
// 	index_DFF3<=index_DFF3;
// 	index_DFF4<=index_DFF4;
// 	index_DFF5<=index_DFF5;
// 	index_DFF6<=index_DFF6;
// 	end
reg [3:0] index_srl;        // 4th layer SRL for index (1-bit)
reg [2:0] index1_srl_0;     // 3th layer SRL for index1[0]
reg [2:0] index1_srl_1;     // 3th layer SRL for index1[1]
reg [1:0] index2_srl_0;     // 2th layer SRL for index2[0]
reg [1:0] index2_srl_1;     // 2th layer SRL for index2[1]
reg [1:0] index2_srl_2;     // 2th layer SRL for index2[2]
reg index_DFF6;

// 4 layers SRL 
always @(posedge clk) begin
    if (Enable) begin
        index_srl <= {index_srl[2:0], index_DFF};
    end
end

// last keep FF（keep Asynchronized Reset）
always @(posedge clk or posedge rst) begin
    if (rst)
        index_DFF6 <= 0;
    else if (Enable)
        index_DFF6 <= index_srl[3];
    else
        index_DFF6 <= index_DFF6;
end


// reg [1:0] index1_DFF2, index1_DFF3, index1_DFF4, index1_DFF5;
// always@(posedge clk or posedge rst)
// if (rst) begin
// 	index1_DFF2<=0;
// 	index1_DFF3<=0;
// 	index1_DFF4<=0;
// 	index1_DFF5<=0;
// 	end
// else if (Enable) begin
// 	index1_DFF2<=index1_DFF;
// 	index1_DFF3<=index1_DFF2;
// 	index1_DFF4<=index1_DFF3;
// 	index1_DFF5<=index1_DFF4;
// 	end
// else begin
// 	index1_DFF2<=index1_DFF2;
// 	index1_DFF3<=index1_DFF3;
// 	index1_DFF4<=index1_DFF4;
// 	index1_DFF5<=index1_DFF5;
// 	end
reg [1:0] index1_DFF5;

// 3 layers SRL （2-bit individual）
always @(posedge clk) begin
    if (Enable) begin
        index1_srl_0 <= {index1_srl_0[1:0], index1_DFF[0]};
        index1_srl_1 <= {index1_srl_1[1:0], index1_DFF[1]};
    end
end

// last keep FF（keep Asynchronized Reset）
always @(posedge clk or posedge rst) begin
    if (rst)
        index1_DFF5 <= 0;
    else if (Enable)
        index1_DFF5 <= {index1_srl_1[2], index1_srl_0[2]};
    else
        index1_DFF5 <= index1_DFF5;
end
	
// reg [2:0] index2_DFF2,index2_DFF3, index2_DFF4;
// always@(posedge clk or posedge rst)
// if (rst) begin
// 	index2_DFF2<=0;
// 	index2_DFF3<=0;
// 	index2_DFF4<=0;
// 	end
// else if (Enable) begin
// 	index2_DFF2<=index2_DFF;
// 	index2_DFF3<=index2_DFF2;
// 	index2_DFF4<=index2_DFF3;
// 	end
// else begin
// 	index2_DFF2<=index2_DFF2;
// 	index2_DFF3<=index2_DFF3;
// 	index2_DFF4<=index2_DFF4;
// 	end
reg [2:0] index2_DFF4;

// 2 layers SRL （3-bit individual）
always @(posedge clk) begin
    if (Enable) begin
        index2_srl_0 <= {index2_srl_0[0], index2_DFF[0]};
        index2_srl_1 <= {index2_srl_1[0], index2_DFF[1]};
        index2_srl_2 <= {index2_srl_2[0], index2_DFF[2]};
    end
end

// last keep FF（keep Asynchronized Reset）
always @(posedge clk or posedge rst) begin
    if (rst)
        index2_DFF4 <= 0;
    else if (Enable)
        index2_DFF4 <= {index2_srl_2[1], index2_srl_1[1], index2_srl_0[1]};
    else
        index2_DFF4 <= index2_DFF4;
end
	
reg [4:0] index4_DFF2;
always@(posedge clk or posedge rst)
if (rst) begin
	index4_DFF2<=0;
	end
else if (Enable) begin
	index4_DFF2<=index4_DFF;
	end
else begin
	index4_DFF2<=index4_DFF2;
	end


always@(*)begin
	case(MMOD)
		3'd0:out={6'b000000, index_DFF6};
		3'd1:out={5'b00000, index1_DFF5};
		3'd2:out={4'b0000, index2_DFF4};  
		3'd3:out={2'b00, index4_DFF2}; 
		3'd4:out=index6; 
		default:out=0;
	endcase
end


//always@(posedge clk or posedge rst)begin
//if (rst) begin
//	index<=7'd63;
//	index_add<=7'd32;
//	end
//else begin 
//	if (counter>=6'd33) begin
//		if (judge0==0) begin
//			index<=7'd63-index_add;
//			index_add<=index_add;
//			end
//		else begin
//			index<=7'd63+index_add;
//			index_add<=index_add;
//			end
//	end
//	else begin
//		index<=7'd63;
//		index_add<=index_add;
//		end
//	end
//end
//
//always@(posedge clk or posedge rst)begin
//if (rst) begin
//	index1=7'd0;
//	index_add1<=7'd16;
//	end
//else begin 
//	if (judge1==0) begin
//		if (index==0) begin
//			index1<=0;
//			index_add1<=index_add1;
//			end
//		else begin
//			index1<=index-index_add1;
//			index_add1<=index_add1;
//			end
//		end
//	else begin
//		index1<=index+index_add1;
//		index_add1<=index_add1;
//		end
//	end
//end
//
//always@(posedge clk or posedge rst)begin
//if (rst) begin
//	index2<=7'd0;
//	index_add2<=7'd8;
//	end
//else begin 
//	if (judge2==0) begin
//		if (index1<=0) begin
//			index2<=7'd0;
//			index_add2<=index_add2;
//			end
//		else begin
//			index2<=index1-index_add2;
//			index_add2<=index_add2;
//			end
//		end
//	else begin
//		index2<=index1+index_add2;
//		index_add2<=index_add2;
//		end
//	end
//end
//
//always@(posedge clk or posedge rst)begin
//if (rst) begin
//	index3<=7'd0;
//	index_add3<=7'd4;
//	end
//else begin 
//	if (judge3==0) begin
//		if (index2==0) begin
//			index3<=7'd0;
//			index_add3<=index_add3;
//			end
//		else begin
//			index3<=index2-index_add3;
//			index_add3<=index_add3;
//			end
//		end
//	else begin
//		index3<=index2+index_add3;
//		index_add3<=index_add3;
//		end
//	end
//end
//
//always@(posedge clk or posedge rst)begin
//if (rst) begin
//	index4<=7'd0;
//	index_add4<=7'd2;
//	end
//else begin 
//	if (judge4==0) begin
//		if(index3==0) begin
//			index4<=7'd0;
//			index_add4<=index_add4;
//			end
//		else begin
//			index4<=index3-index_add4;
//			index_add4<=index_add4;
//			end
//		end
//	else begin
//		index4<=index3+index_add4;
//		index_add4<=index_add4;
//		end
//	end
//end
//
//
//always@(posedge clk or posedge rst)begin
//if (rst) begin
//	index5<=7'd0;
//	index_add5<=7'd1;
//	end
//else begin 
//	if (judge5==0) begin
//		if(index4==0) begin
//			index5<=7'd0;
//			index_add5<=index_add5;
//			end
//		else begin
//			index5<=index4-index_add5;
//			index_add5<=index_add5;
//			end
//		end
//	else begin
//		index5<=index4+index_add5;
//		index_add5<=index_add5;
//		end
//	end
//end
//
//always@(posedge clk or posedge rst)begin
//if (rst) begin
//	index6<=7'd0;
//	end
//else begin 
//	if (judge6==0) begin
//		if (index5==0)
//			index6<=7'd0;
//		else
//			index6<=index5;
//		end
//	else begin
//		index6<=index5+1;
//		end
//	end
//end

//always@(*) begin
//if (counter>=6'd33)
//	out=index6;
//else
//   out=0;
//end
//always@(*) begin
//if (BMOD==2'd0 && counter>=6'd9)
//	out=index6;
//else if (BMOD==2'd1 && counter>=6'd17)
//	out=index6;
//else if (BMOD==2'd2 && counter>=6'd33)
//	out=index6;
//else
//   out=0;
//end




endmodule
