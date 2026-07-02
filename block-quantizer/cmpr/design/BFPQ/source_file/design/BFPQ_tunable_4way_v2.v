`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:05:19 08/26/2018 
// Design Name: 
// Module Name:    BFPQ 
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
module BFPQ_tunable_4way_v2(ClockBFPQ, clear , S2POUTI1, S2POUTI2, S2POUTI3, S2POUTI4, S2POUTQ1, S2POUTQ2, S2POUTQ3, S2POUTQ4, BMOD, MMOD, EnableIn/*InputI, InputQ, BMOD, EnableIn, MMOD, sel*//*, FMOD, SquareI, SquareQ, Summation, VarianceSelect, MaxValue*//*, SAOUT1*/, Ce, Cw/*, TempRAMOutI, TempRAMOutQ,*/ 
				/*SAOUT2I, SAOUT2Q, DataMulScalingI, DataMulScalingQ*//*, MantissaI1,  MantissaI2, MantissaI3, MantissaI4, MantissaQ1, MantissaQ2, MantissaQ3, MantissaQ4*/ , fOutValid, fBlockEnd  /*, ClockBFPQ*/
				/*AbsI, AbsQ,*/ /*, SignI1, SignQ1, SignI2, SignQ2, SignI3, SignQ3, SignI4, SignQ4*//*, S2POUTI1*/, MantissaI1, MantissaI2, MantissaI3, MantissaI4, MantissaQ1, MantissaQ2, MantissaQ3, MantissaQ4, SignI1, SignQ1, SignI2, SignQ2, SignI3, SignQ3, SignI4, SignQ4/*, ClockBFPQ, Clock, cnt_2*//*, Enable, EnableOr_sub, counter_S2P*/
    );

parameter ADC_WORDLENGTH=4'd14;

input ClockBFPQ, clear;
input [1:0] BMOD;
input [2:0] MMOD;
input EnableIn;
//input FMOD;
input signed [ADC_WORDLENGTH-1:0] S2POUTI1, S2POUTI2, S2POUTI3, S2POUTI4, S2POUTQ1, S2POUTQ2, S2POUTQ3, S2POUTQ4;
//input sel;
//output [12:0] MaxValue;//2.11

output [2:0] Ce;
output [2:0] Cw;
//output counter_32;
//output [13:0] S2POUTI1;
//output ClockBFPQ;
//output Clock;
//output cnt_2;
//output signed[ADC_WORDLENGTH-1:0] TempRAMOutI, TempRAMOutQ;
//output [ADC_WORDLENGTH-2:0] TempRAMOutI, TempRAMOutQ;

//output [17:0] DataMulScalingI, DataMulScalingQ;
//output [6:0] MantissaI1, MantissaI2, MantissaI3, MantissaI4;
//output [6:0] MantissaQ1, MantissaQ2, MantissaQ3, MantissaQ4;
output  [6:0] MantissaI1, MantissaI2, MantissaI3, MantissaI4, MantissaQ1, MantissaQ2, MantissaQ3, MantissaQ4;
output  SignI1, SignQ1, SignI2, SignQ2, SignI3, SignQ3, SignI4, SignQ4;
//output Enable, EnableOr_sub;
//output [1:0]counter_S2P;
//output [12:0] AbsI, AbsQ;
//output SignI1, SignQ1, SignI2, SignQ2, SignI3, SignQ3, SignI4, SignQ4;
// wire SignOutI1, SignOutI2, SignOutI3, SignOutI4, SignOutQ1, SignOutQ2, SignOutQ3, SignOutQ4, TempSignI1, TempSignI2, TempSignI3, TempSignI4,
// 		TempSignQ1, TempSignQ2, TempSignQ3, TempSignQ4, TempSignI1_DFF, TempSignI2_DFF, TempSignI3_DFF, TempSignI4_DFF, TempSignQ1_DFF, 
// 		TempSignQ2_DFF, TempSignQ3_DFF, TempSignQ4_DFF, TempSignI1_DFF2, TempSignI2_DFF2, TempSignI3_DFF2, TempSignI4_DFF2, TempSignQ1_DFF2, 
// 		TempSignQ2_DFF2, TempSignQ3_DFF2, TempSignQ4_DFF2, TempSignI1_DFF3, TempSignI2_DFF3, TempSignI3_DFF3, TempSignI4_DFF3, TempSignQ1_DFF3, 
// 		TempSignQ2_DFF3, TempSignQ3_DFF3, TempSignQ4_DFF3, TempSignI1_DFF4, TempSignI2_DFF4, TempSignI3_DFF4, TempSignI4_DFF4, TempSignQ1_DFF4, 
// 		TempSignQ2_DFF4, TempSignQ3_DFF4, TempSignQ4_DFF4, TempSignI1_DFF5, TempSignI2_DFF5, TempSignI3_DFF5, TempSignI4_DFF5, TempSignQ1_DFF5, 
// 		TempSignQ2_DFF5, TempSignQ3_DFF5, TempSignQ4_DFF5, TempSignI1_DFF6, TempSignI2_DFF6, TempSignI3_DFF6, TempSignI4_DFF6, TempSignQ1_DFF6, 
// 		TempSignQ2_DFF6, TempSignQ3_DFF6, TempSignQ4_DFF6, TempSignI1_DFF7, TempSignI2_DFF7, TempSignI3_DFF7, TempSignI4_DFF7, TempSignQ1_DFF7, 
// 		TempSignQ2_DFF7, TempSignQ3_DFF7, TempSignQ4_DFF7, TempSignI1_DFF8, TempSignI2_DFF8, TempSignI3_DFF8, TempSignI4_DFF8, TempSignQ1_DFF8, 
// 		TempSignQ2_DFF8, TempSignQ3_DFF8, TempSignQ4_DFF8, TempSignI1_DFF9, TempSignI2_DFF9, TempSignI3_DFF9, TempSignI4_DFF9, TempSignQ1_DFF9, 
// 		TempSignQ2_DFF9, TempSignQ3_DFF9, TempSignQ4_DFF9, TempSignI1_DFF10, TempSignI2_DFF10, TempSignI3_DFF10, TempSignI4_DFF10, TempSignQ1_DFF10, 
// 		TempSignQ2_DFF10, TempSignQ3_DFF10, TempSignQ4_DFF10, TempSignI1_DFF11, TempSignI2_DFF11, TempSignI3_DFF11, TempSignI4_DFF11, TempSignQ1_DFF11, 
// 		TempSignQ2_DFF11, TempSignQ3_DFF11, TempSignQ4_DFF11, TempSignI1_DFF12, TempSignI2_DFF12, TempSignI3_DFF12, TempSignI4_DFF12, TempSignQ1_DFF12, 
// 		TempSignQ2_DFF12, TempSignQ3_DFF12, TempSignQ4_DFF12;
wire SignOutI1, SignOutI2, SignOutI3, SignOutI4, SignOutQ1, SignOutQ2, SignOutQ3, SignOutQ4, TempSignI1, TempSignI2, TempSignI3, TempSignI4,
		TempSignQ1, TempSignQ2, TempSignQ3, TempSignQ4;

// Sign Pipeline SRL
reg [11:0] SignI1_srl, SignQ1_srl, SignI2_srl, SignQ2_srl;
reg [11:0] SignI3_srl, SignQ3_srl, SignI4_srl, SignQ4_srl;

reg [2:0] Counter;

reg FMOD;
//wire [27:0]TempSquareI,TempSquareQ;
// wire [2:0] TempCe, Ce_DFF, Ce_DFF2, Ce_DFF3, Ce_DFF4, Ce_DFF5, Ce_DFF6, Ce_DFF7, Ce_DFF8, Ce_DFF9;
wire [2:0] TempCe, Ce_DFF, Ce_DFF2, Ce_DFF3;
// Ce Pipeline SRL (6 lyaers，3-bit width need 3 SRL）
reg [5:0] Ce_srl_0, Ce_srl_1, Ce_srl_2;

// wire [2:0] TempCw, Cw_DFF, Cw_DFF2, Cw_DFF3, Cw_DFF4, Cw_DFF5, Cw_DFF6, Cw_DFF7, Cw_DFF8;
wire [2:0] TempCw, Cw_DFF;
// Cw Pipeline SRL (7 layers，3-bit width need 3 SRL）
reg [6:0] Cw_srl_0, Cw_srl_1, Cw_srl_2;

wire [6:0] MantissaI1, MantissaI2, MantissaI3, MantissaI4;
wire [6:0] MantissaQ1, MantissaQ2, MantissaQ3, MantissaQ4;

wire [17:0] DataMulScalingI1, DataMulScalingQ1, DataMulScalingI2, DataMulScalingQ2, DataMulScalingI3, DataMulScalingQ3, DataMulScalingI4, DataMulScalingQ4, 
				DataMulScalingI1_DFF, DataMulScalingQ1_DFF, DataMulScalingI2_DFF, DataMulScalingQ2_DFF, DataMulScalingI3_DFF, DataMulScalingQ3_DFF, DataMulScalingI4_DFF, DataMulScalingQ4_DFF;
wire [6:0] Iout1, Qout1, Iout2, Qout2, Iout3, Qout3, Iout4, Qout4;
wire [12:0] MaxValue, MaxValue_DFF;
wire [13:0] Maxtune_DFF, Maxtune_DFF2;
wire [9:0] InverseAlpha;
wire [13:0] Maxtune;//2.12


wire [11:0] ThresholdExp1, ThresholdExp2, ThresholdExp3, ThresholdExp4, ThresholdExp5, ThresholdExp6, ThresholdExp7, ThresholdExp8;

reg [11:0] A;
wire [8:0]  ThresholdW0, ThresholdW1, ThresholdW2, ThresholdW3, ThresholdW4, ThresholdW5, ThresholdW6;//, ThresholdW7, ThresholdW8, ThresholdW9, ThresholdW10, ThresholdW11, ThresholdW12, ThresholdW13, ThresholdW14;
wire [10:0] InvW;
// wire [12:0] TempRAMOutI1, TempRAMOutQ1, TempRAMOutI2, TempRAMOutQ2, TempRAMOutI3, TempRAMOutQ3, TempRAMOutI4, TempRAMOutQ4, 
// 				TempRAMOutI1_DFF, TempRAMOutQ1_DFF, TempRAMOutI2_DFF, TempRAMOutQ2_DFF, TempRAMOutI3_DFF, TempRAMOutQ3_DFF, TempRAMOutI4_DFF, TempRAMOutQ4_DFF,
// 				TempRAMOutI1_DFF2, TempRAMOutQ1_DFF2, TempRAMOutI2_DFF2, TempRAMOutQ2_DFF2, TempRAMOutI3_DFF2, TempRAMOutQ3_DFF2, TempRAMOutI4_DFF2, TempRAMOutQ4_DFF2, 
// 				TempRAMOutI1_DFF3, TempRAMOutQ1_DFF3, TempRAMOutI2_DFF3, TempRAMOutQ2_DFF3, TempRAMOutI3_DFF3, TempRAMOutQ3_DFF3, TempRAMOutI4_DFF3, TempRAMOutQ4_DFF3, 
// 				TempRAMOutI1_DFF4, TempRAMOutQ1_DFF4, TempRAMOutI2_DFF4, TempRAMOutQ2_DFF4, TempRAMOutI3_DFF4, TempRAMOutQ3_DFF4, TempRAMOutI4_DFF4, TempRAMOutQ4_DFF4,
// 				TempRAMOutI1_DFF5, TempRAMOutQ1_DFF5, TempRAMOutI2_DFF5, TempRAMOutQ2_DFF5, TempRAMOutI3_DFF5, TempRAMOutQ3_DFF5, TempRAMOutI4_DFF5, TempRAMOutQ4_DFF5;
wire [12:0] TempRAMOutI1, TempRAMOutQ1, TempRAMOutI2, TempRAMOutQ2, TempRAMOutI3, TempRAMOutQ3, TempRAMOutI4, TempRAMOutQ4,
				TempRAMOutI1_DFF5, TempRAMOutQ1_DFF5, TempRAMOutI2_DFF5, TempRAMOutQ2_DFF5, TempRAMOutI3_DFF5, TempRAMOutQ3_DFF5, TempRAMOutI4_DFF5, TempRAMOutQ4_DFF5;

// TempRAMOut Pipeline SRL （4 layer reg shift，13-bit × 8 ch）
reg [3:0] RAMOutI1_srl [12:0];
reg [3:0] RAMOutQ1_srl [12:0];
reg [3:0] RAMOutI2_srl [12:0];
reg [3:0] RAMOutQ2_srl [12:0];
reg [3:0] RAMOutI3_srl [12:0];
reg [3:0] RAMOutQ3_srl [12:0];
reg [3:0] RAMOutI4_srl [12:0];
reg [3:0] RAMOutQ4_srl [12:0];

//CLOCK_GEN instance_name
//   (// Clock in ports
//    .CLK_IN1(Clock_Or),      // IN
//    // Clock out ports
//    .CLK_OUT1(ClockBFPQ),     // OUT
////    .CLK_OUT2(ClockBFPQ),     // OUT
//    // Status and control signals
//    .LOCKED(LOCKED));
//div4 dv4(.clk(Clock_Or),.rst_n(rst),.o_clk_2(ClockBFPQ));
////assign Clock=Clock_Or;

//always@(posedge ClockBFPQ or posedge rst)begin//////////////Enable changed
//	if(rst==1)
//		counter<=0;
//	else if(Enable)begin
//		if(BMOD_DFF==2'd0 && counter==3'd1)
//			counter<=0;
//		else if(BMOD_DFF==2'd1 && counter==3'd3)
//			counter<=0;
//		else
//			counter<=counter+1;
//			end
//	else
//		counter<=counter;
//end

//reg [2:0] EnableCounter;
//always@(*)
//if(EnableAlignBAQClock)//
//	Counter_flag=1;
//else
//	Counter_flag=Counter_flag_DFF;

//always@(posedge Clock or posedge rst)begin 
//if(rst == 1'b1)
//	EnableCounter<=0;
//else if(EnableAlignBAQClock)
//	if((counter_S2P==0) | EnableCounter==3'd4)
//		EnableCounter<=0;
//	else
//		EnableCounter<=EnableCounter+1;
//else
//	EnableCounter<=EnableCounter;
//end
//reg [9:0] counter_inter;
//always@(posedge ClockBFPQ or posedge clearIn)begin 
//if (clearIn)
//	counter_inter<=0;
//else if(counter_inter==10'd1023)
//	counter_inter<=counter_inter;
//else
//	counter_inter<=counter_inter+1;
//	end
//	
//reg signed [13:0] S2POUTI1, S2POUTI2, S2POUTI3, S2POUTI4, S2POUTQ1, S2POUTQ2, S2POUTQ3, S2POUTQ4;
//reg EnableIn;
//reg clear;
//(* KEEP="TRUE"*)reg [1:0] BMOD;
//(* KEEP="TRUE"*)reg [2:0] MMOD;
//(* KEEP="TRUE"*)reg sel;

//wire signed [13:0] S2POUTI1, S2POUTI2, S2POUTI3, S2POUTI4, S2POUTQ1, S2POUTQ2, S2POUTQ3, S2POUTQ4;
wire EnableIn;
wire clear;
(* KEEP="TRUE"*)wire [1:0] BMOD;
(* KEEP="TRUE"*)wire [2:0] MMOD;
//(* KEEP="TRUE"*)wire sel;
//




//assign BMOD=2'd2;
//assign MMOD=3'd3;
//assign sel=1'd1;

	

//wire [2:0] Counter_DFF;
//reg Counter_flag, Counter_flag_DFF;
//always@(*)
//if(Enable)
//	Counter_flag=1;
//else
//	Counter_flag=Counter_flag_DFF;
//
//always@(posedge ClockBFPQ or posedge clear)begin 
//if(clear == 1'b1)
//	Counter_flag_DFF<=0;
//else
//	Counter_flag_DFF<=Counter_flag;
//end





//reg EnableOr_sub;
//reg EnableOr;
//wire EnableCounter;
//assign EnableCounter=(Enable)|(EnableAlignBAQClock);

//always@(posedge Clock or posedge rst)begin 
//if(rst)
//	EnableOr_sub<=0;
//else if(Enable)
//	if(counter_S2P==0)
//		EnableOr_sub<=1;
//	else
//		EnableOr_sub<=EnableOr_sub;
//else
//	EnableOr_sub<=0;
//end
//
//always@(*)
//if((Enable==0)&&(counter_S2P==2'd0))
//	EnableOr=0;
//else
//	EnableOr=(EnableOr_sub)|(EnableAlignBAQClock);
//assign EnableOr=(EnableOr_sub)|(EnableAlignBAQClock);





//always@(posedge Clock or posedge rst)
//if(rst)
//EnableOr<=0;
//else if(Enable)
//	if((counter_S2P==0) && (Enable))
//		EnableOr<=1;
//	else
//		EnableOr<=EnableOr;
//else
//	EnableOr<=0;
//else if((counter_S2P==0) && (Enable) && (EnableOr==0))
//EnableOr<=1;
//else
//EnableOr<=0;


//always@(posedge ClockBFPQ or posedge rst)begin 
//if(rst == 1'b1)
//	Counter <= 0;
//else if(~Counter_flag && Enable)
//	Counter <= BLOCK_SIZE;
//else if(Counter_flag && Enable)
//	if (Counter == BLOCK_SIZE)
//		Counter <= 3'b0;
//	else 
//		Counter <= Counter + 1'b1;
////Counter <= Counter + 1'b1;
////else if(Enable)begin
////if (~Counter_flag)
////Counter <= BLOCK_SIZE;
////else if (Counter == BLOCK_SIZE)
////Counter <= 3'b0;
////else 
////Counter <= Counter + 1'b1;
////end
//else
//Counter <= Counter;
//end
//always@(posedge ClockBFPQ or posedge rst)begin 
//if(rst == 1'b1)
//Counter <= BLOCK_SIZE-2'd1;
//else if(Enable)begin
//if (Counter == BLOCK_SIZE)
//Counter <= 3'b0;
//else 
//Counter <= Counter + 1'b1;
//end
//else
//Counter <= Counter;
//end


(* KEEP="TRUE"*)wire [1:0] BMOD_DFF;
(* KEEP="TRUE"*)wire [2:0] MMOD_DFF;
//always@(posedge ClockBFPQ or posedge clear)begin
//if(clear)
//	MMOD_DFF<=0;
////else if(Enable)
////	MMOD_DFF<=MMOD;
//else
//	MMOD_DFF<=MMOD;
//	end

//////////////��J�T���L�@��DFF///////////
 wire EnableInD1;
 wire Enable;
//bfpq_NESingleFF #(1) NEFF(.Rst(rst),.DInput(EnableIn),.QOutput(EnableInD1),.Clock(Clock));
bfpq_NESingleFF #(1) NEFF2(.Rst(clear),.DInput(EnableIn),.QOutput(Enable),.Clock(ClockBFPQ));
bfpq_NESingleFF #(3) NEFF9(.QOutput(MMOD_DFF), .DInput(MMOD), .Clock(ClockBFPQ), .Rst(clear));

//always@(posedge ClockBFPQ or posedge clear)begin
//if(clear)
//	BMOD_DFF<=0;
////else if(Enable)
////	BMOD_DFF<=BMOD;
//else
//	BMOD_DFF<=BMOD;
//	end
	
bfpq_NESingleFF #(2) NEFF10(.QOutput(BMOD_DFF), .DInput(BMOD), .Clock(ClockBFPQ), .Rst(clear));

//always@(posedge ClockBFPQ)begin
//
//	BMOD_DFF<=BMOD;
//	end
wire signed[13:0] S2POUTI1_NEDFF, S2POUTI2_NEDFF, S2POUTI3_NEDFF, S2POUTI4_NEDFF, S2POUTQ1_NEDFF, S2POUTQ2_NEDFF, S2POUTQ3_NEDFF, S2POUTQ4_NEDFF;
bfpq_NESingleFF #(14) FF1(.QOutput(S2POUTI1_NEDFF), .DInput(S2POUTI1), .Clock(ClockBFPQ), .Rst(clear));
bfpq_NESingleFF #(14) FF2(.QOutput(S2POUTI2_NEDFF), .DInput(S2POUTI2), .Clock(ClockBFPQ), .Rst(clear));
bfpq_NESingleFF #(14) FF3(.QOutput(S2POUTI3_NEDFF), .DInput(S2POUTI3), .Clock(ClockBFPQ), .Rst(clear));
bfpq_NESingleFF #(14) FF4(.QOutput(S2POUTI4_NEDFF), .DInput(S2POUTI4), .Clock(ClockBFPQ), .Rst(clear));
bfpq_NESingleFF #(14) FF5(.QOutput(S2POUTQ1_NEDFF), .DInput(S2POUTQ1), .Clock(ClockBFPQ), .Rst(clear));
bfpq_NESingleFF #(14) FF6(.QOutput(S2POUTQ2_NEDFF), .DInput(S2POUTQ2), .Clock(ClockBFPQ), .Rst(clear));
bfpq_NESingleFF #(14) FF7(.QOutput(S2POUTQ3_NEDFF), .DInput(S2POUTQ3), .Clock(ClockBFPQ), .Rst(clear));
bfpq_NESingleFF #(14) FF8(.QOutput(S2POUTQ4_NEDFF), .DInput(S2POUTQ4), .Clock(ClockBFPQ), .Rst(clear));
//////////////��J�T���L�@��DFF///////////
//////////////��J�T���PEnable�л�///////////
wire signed[13:0] S2POUTI1_DFF, S2POUTI2_DFF, S2POUTI3_DFF, S2POUTI4_DFF, S2POUTQ1_DFF, S2POUTQ2_DFF, S2POUTQ3_DFF, S2POUTQ4_DFF;	
bfpq_SingleFF #(14) IF10(.Enable(Enable),.Rst(clear),.DInput(S2POUTI1_NEDFF),.QOutput(S2POUTI1_DFF),.Clock(ClockBFPQ));
bfpq_SingleFF #(14) IF11(.Enable(Enable),.Rst(clear),.DInput(S2POUTI2_NEDFF),.QOutput(S2POUTI2_DFF),.Clock(ClockBFPQ));
bfpq_SingleFF #(14) IF20(.Enable(Enable),.Rst(clear),.DInput(S2POUTI3_NEDFF),.QOutput(S2POUTI3_DFF),.Clock(ClockBFPQ));
bfpq_SingleFF #(14) IF21(.Enable(Enable),.Rst(clear),.DInput(S2POUTI4_NEDFF),.QOutput(S2POUTI4_DFF),.Clock(ClockBFPQ));
bfpq_SingleFF #(14) IF30(.Enable(Enable),.Rst(clear),.DInput(S2POUTQ1_NEDFF),.QOutput(S2POUTQ1_DFF),.Clock(ClockBFPQ));
bfpq_SingleFF #(14) IF31(.Enable(Enable),.Rst(clear),.DInput(S2POUTQ2_NEDFF),.QOutput(S2POUTQ2_DFF),.Clock(ClockBFPQ));
bfpq_SingleFF #(14) IF40(.Enable(Enable),.Rst(clear),.DInput(S2POUTQ3_NEDFF),.QOutput(S2POUTQ3_DFF),.Clock(ClockBFPQ));
bfpq_SingleFF #(14) IF41(.Enable(Enable),.Rst(clear),.DInput(S2POUTQ4_NEDFF),.QOutput(S2POUTQ4_DFF),.Clock(ClockBFPQ));
//////////////��J�T���PEnable�л�///////////

//////////////��ܦbMMOD�]�w�U���ƶ���0���̤j��ɵ�Scaling Judgement��///////
always@(*)begin
	case(MMOD_DFF)
		3'd0:A=12'b011100111101;
		3'd1:A=12'b100011010011;
		3'd2:A=12'b100110000000;
		3'd3:A=12'b101011011100;
		3'd4:A=12'b101100111001;
		default:A=12'd0;
	endcase
end
//////////////��ܦbMMOD�]�w�U���ƶ���0���̤j��ɵ�Scaling Judgement��///////

//////////////��ܦbBMOD�]�w�U��BLOCK SIZE///////
reg [2:0] BLOCK_SIZE;
always@(*) begin
	case(BMOD_DFF)
		2'd0:BLOCK_SIZE=3'd1;
		2'd1:BLOCK_SIZE=3'd3;
		2'd2:BLOCK_SIZE=3'd7;
		default:BLOCK_SIZE=3'd0;
	endcase
end
//////////////��ܦbBMOD�]�w�U��BLOCK SIZE///////

//////////////��ܦbMMOD��BMOD�]�w�U��F�]�w///////
always@(*) begin
	case(MMOD_DFF)
		3'd0:FMOD=1'd0;
		3'd1:begin
				case(BMOD_DFF)
					2'd0:FMOD=1'd0;
					2'd1:FMOD=1'd1;
					default:FMOD=1'd0;
				endcase
			  end
		3'd2:begin
				case(BMOD_DFF)
					2'd0:FMOD=1'd0;
					2'd1:FMOD=1'd0;
					2'd2:FMOD=1'd1;
					default:FMOD=1'd0;
				endcase
			  end
		3'd3:begin
				case(BMOD_DFF)
					2'd0:FMOD=1'd0;
					2'd1:FMOD=1'd0;
					2'd2:FMOD=1'd1;
					default:FMOD=1'd0;
				endcase
			  end
		3'd4:begin
				case(BMOD_DFF)
					2'd0:FMOD=1'd0;
					2'd1:FMOD=1'd0;
					2'd2:FMOD=1'd1;
					default:FMOD=1'd0;
				endcase
			  end
		default:FMOD=1'd0;
	endcase
end
//////////////��ܦbMMOD��BMOD�]�w�U��F�]�w///////

//////////////�]�w���ĭȶ}�l��m�ΨC�Ӱ϶��������a��////////

output fOutValid;
reg fOutValid_sub;
reg [4:0] ValidCounter;
output  fBlockEnd;
reg fBlockEnd;
reg [2:0] fBlockEndCounter;
always@(posedge ClockBFPQ or posedge clear)begin
if(clear)
ValidCounter <= 5'b0;
else begin
case (Enable)
1'd1:begin
		if(ValidCounter == BLOCK_SIZE+4'd14)//10
      ValidCounter <= ValidCounter;
		else
		ValidCounter <= ValidCounter+1'b1;
		end
default:begin
		ValidCounter <= ValidCounter;
		end
endcase
end
end

reg fOutValid;
always@(posedge ClockBFPQ or posedge clear)begin
if(clear)
fOutValid <= 1'b0;
else begin
case (Enable)
1'b1:begin
		if(ValidCounter ==  BLOCK_SIZE+4'd14)//10
		fOutValid <= 1'b1;
		else
		fOutValid <= fOutValid;		
		end
default:fOutValid <= 0;
endcase
end
end
//assign fOutValid=(Enable)&(fOutValid_sub);

always@(posedge ClockBFPQ or posedge clear)begin
if(clear)
fBlockEndCounter <= 3'b0;

else begin
case(fOutValid)
1'd1:begin
		if (fBlockEndCounter == BLOCK_SIZE)
		fBlockEndCounter <= 3'd0;
		else
		fBlockEndCounter <= fBlockEndCounter+1'b1;
		end
default:fBlockEndCounter <= fBlockEndCounter;
endcase
end
end

always@(posedge ClockBFPQ or posedge clear)begin
if(clear) fBlockEnd <=1'b0;
else begin
case(fOutValid)
1'd1:begin
		if (fBlockEndCounter == BLOCK_SIZE-1'b1)
		fBlockEnd <= 1;
		else
		fBlockEnd <= 0;
		end
default:fBlockEnd <= fBlockEnd;
endcase
end
end

//////////////�]�w���ĭȶ}�l��m�ΨC�Ӱ϶��������a��////////

//////////////�p�ƾ���Max��////////////////
always@(posedge ClockBFPQ or posedge clear)begin 
if(clear == 1'b1)
Counter <= 0;
else if(Enable)begin
//if (~Counter_flag_DFF)
//Counter <= BLOCK_SIZE;
if (Counter == BLOCK_SIZE)
Counter <= 3'b0;
else 
Counter <= Counter + 1'b1;
end
else
Counter <= Counter;
end
//////////////�p�ƾ���Max��////////////////

/////////////��JTable///////////
ExpTable ET(.MMOD(MMOD_DFF), .bound1(ThresholdExp1), .bound2(ThresholdExp2), .bound3(ThresholdExp3), .bound4(ThresholdExp4), .bound5(ThresholdExp5), .bound6(ThresholdExp6), .bound7(ThresholdExp7));
WTable WT(.FMOD(FMOD), .bound0(ThresholdW0), .bound1(ThresholdW1), .bound2(ThresholdW2), .bound3(ThresholdW3), .bound4(ThresholdW4), .bound5(ThresholdW5), .bound6(ThresholdW6));
InverseAlphaTable AT(.MMOD(MMOD_DFF), .BMOD(BMOD_DFF), .InverseAlpha(InverseAlpha));
/////////////��JTable///////////

// input EnableIn;

//----------------------------------------


//Flip Flop
//wire signed[13:0]InputID2,InputQD2;

//wire signed[13:0] InputID1,InputQD1, InputID2,InputQD2, InputID3,InputQD3;
//wire signed[13:0] S2POUTI1, S2POUTI2, S2POUTI3, S2POUTI4, S2POUTQ1, S2POUTQ2, S2POUTQ3, S2POUTQ4;
		

//bfpq_NESingleFF #(14) NEIF0(.Rst(rst),.DInput(InputI),.QOutput(InputID1),.Clock(Clock));
//bfpq_NESingleFF #(14) NEIF1(.Rst(rst),.DInput(InputQ),.QOutput(InputQD1),.Clock(Clock));
//bfpq_NESingleFF #(14) NEIF2(.Rst(rst),.DInput(InputID1),.QOutput(InputID2),.Clock(Clock));
//bfpq_NESingleFF #(14) NEIF3(.Rst(rst),.DInput(InputQD1),.QOutput(InputQD2),.Clock(Clock));
//
//bfpq_SingleFF #(14) IF0(.Enable(Enable),.Rst(rst),.DInput(InputID2),.QOutput(InputID3),.Clock(Clock));
//bfpq_SingleFF #(14) IF1(.Enable(Enable),.Rst(rst),.DInput(InputQD2),.QOutput(InputQD3),.Clock(Clock));


//reg EnableAlignBAQClock;
//always@(posedge ClockBFPQ or posedge rst)begin
//if (rst)
//   EnableAlignBAQClock<=1'b0;
//else
//   EnableAlignBAQClock<=Enable;
//end
//
//reg [1:0]counter_S2P;
//always@(posedge Clock or posedge rst)begin
//if(rst)
//counter_S2P<=2'd0;
//else if((Enable==1'b1)&&(counter_start))//////////////////////
//counter_S2P<=counter_S2P+1'b1;
//else
//counter_S2P<=counter_S2P;
//end
//
//reg counter_start, counter_start_DFF;
//always@(*)//////////////////////
//if(EnableAlignBAQClock)
//counter_start=1;
//else
//counter_start=counter_start_DFF;
//
//always@(posedge Clock or posedge rst)//////////////////////
//if(rst)
//counter_start_DFF<=0;
//else
//counter_start_DFF<=counter_start;
//
//// Check for time difference between Enable and EnableAlignBAQClock
//reg [2:0] CounterDifference;
//always@(posedge Clock or posedge rst)begin
//if (rst)
//	CounterDifference<=3'd0;
//else if (BufferOneRound)//////////////////////////////////////////////////
//	CounterDifference<=CounterDifference;
////else if (CounterDifference==3'd4)
////	CounterDifference<=3'd4;
////else if ((~Enable)&(~EnableAlignBAQClock))
////	CounterDifference<=0;
//else if (Enable&(~EnableAlignBAQClock))
//	CounterDifference<=CounterDifference+1'b1;
//else
//   CounterDifference<=CounterDifference;
//end 
// 
//reg BufferOneRound;
//always@(posedge Clock or posedge rst)begin
//if (rst)
//BufferOneRound<=1'b0;
//else if ((EnableAlignBAQClock)&&(counter_S2P==2'd3))
//BufferOneRound<=1'b1;
//else
//BufferOneRound<=BufferOneRound;
//end 

//S2P_4way S2P1(.Enable(Enable), .DATAIn(InputID3), .Out1(S2POUTI1), .Out2(S2POUTI2), .Out3(S2POUTI3), .Out4(S2POUTI4), .counter(counter_S2P), .BufferOneRound(BufferOneRound), .CounterDifference(CounterDifference), .Clock(Clock), .ClockBFPQ(ClockBFPQ), .RST(rst));
//S2P_4way S2P2(.Enable(Enable), .DATAIn(InputQD3), .Out1(S2POUTQ1), .Out2(S2POUTQ2), .Out3(S2POUTQ3), .Out4(S2POUTQ4), .counter(counter_S2P), .BufferOneRound(BufferOneRound), .CounterDifference(CounterDifference), .Clock(Clock), .ClockBFPQ(ClockBFPQ), .RST(rst));




//DFF #(3) FF64(.out(Counter_DFF), .in(Counter), .clk(ClockBFPQ), .Enable(EnableOr), .rst(rst));
//////////

////////////�N�T���������/////////////
wire [12:0] AbsI1, AbsQ1, AbsI2, AbsQ2, AbsI3, AbsQ3, AbsI4, AbsQ4;
ABS Abs1(.inI(S2POUTI1_DFF), .inQ(S2POUTQ1_DFF), .outI(AbsI1), .outQ(AbsQ1), .signI(SignOutI1), .signQ(SignOutQ1));
ABS Abs2(.inI(S2POUTI2_DFF), .inQ(S2POUTQ2_DFF), .outI(AbsI2), .outQ(AbsQ2), .signI(SignOutI2), .signQ(SignOutQ2));
ABS Abs3(.inI(S2POUTI3_DFF), .inQ(S2POUTQ3_DFF), .outI(AbsI3), .outQ(AbsQ3), .signI(SignOutI3), .signQ(SignOutQ3));
ABS Abs4(.inI(S2POUTI4_DFF), .inQ(S2POUTQ4_DFF), .outI(AbsI4), .outQ(AbsQ4), .signI(SignOutI4), .signQ(SignOutQ4));
////////////�N�T���������/////////////

//wire [12:0] TempAbsI1, TempAbsI2, TempAbsI3, TempAbsI4, TempAbsQ1, TempAbsQ2, TempAbsQ3, TempAbsQ4;

//DFF #(13)  FF200(.out(AbsI1), .in(TempAbsI1), .clk(ClockBFPQ), .Enable(EnableOr), .rst(rst));
//DFF #(13)  FF201(.out(AbsI2), .in(TempAbsI2), .clk(ClockBFPQ), .Enable(EnableOr), .rst(rst));
//DFF #(13)  FF202(.out(AbsI3), .in(TempAbsI3), .clk(ClockBFPQ), .Enable(EnableOr), .rst(rst));
//DFF #(13)  FF203(.out(AbsI4), .in(TempAbsI4), .clk(ClockBFPQ), .Enable(EnableOr), .rst(rst));
//DFF #(13)  FF204(.out(AbsQ1), .in(TempAbsQ1), .clk(ClockBFPQ), .Enable(EnableOr), .rst(rst));
//DFF #(13)  FF205(.out(AbsQ2), .in(TempAbsQ2), .clk(ClockBFPQ), .Enable(EnableOr), .rst(rst));
//DFF #(13)  FF206(.out(AbsQ3), .in(TempAbsQ3), .clk(ClockBFPQ), .Enable(EnableOr), .rst(rst));
//DFF #(13)  FF207(.out(AbsQ4), .in(TempAbsQ4), .clk(ClockBFPQ), .Enable(EnableOr), .rst(rst));

//////////////�NSign�T��������H�F��P��L��X�T���P�ɿ�X/////////////
// InputBuffering_v2 #(1) BUFFER1(.Enable(Enable), .clk(ClockBFPQ)/*, .rst(rst)*/, .DInputI(SignOutI1), .DInputQ(SignOutQ1), .TempRAMOutI(TempSignI1), .TempRAMOutQ(TempSignQ1), .BLOCK_SIZE(BLOCK_SIZE), .Counter(Counter));
// InputBuffering_v2 #(1) BUFFER2(.Enable(Enable), .clk(ClockBFPQ)/*, .rst(rst)*/, .DInputI(SignOutI2), .DInputQ(SignOutQ2), .TempRAMOutI(TempSignI2), .TempRAMOutQ(TempSignQ2), .BLOCK_SIZE(BLOCK_SIZE), .Counter(Counter));
// InputBuffering_v2 #(1) BUFFER3(.Enable(Enable), .clk(ClockBFPQ)/*, .rst(rst)*/, .DInputI(SignOutI3), .DInputQ(SignOutQ3), .TempRAMOutI(TempSignI3), .TempRAMOutQ(TempSignQ3), .BLOCK_SIZE(BLOCK_SIZE), .Counter(Counter));
// InputBuffering_v2 #(1) BUFFER4(.Enable(Enable), .clk(ClockBFPQ)/*, .rst(rst)*/, .DInputI(SignOutI4), .DInputQ(SignOutQ4), .TempRAMOutI(TempSignI4), .TempRAMOutQ(TempSignQ4), .BLOCK_SIZE(BLOCK_SIZE), .Counter(Counter));
// DFF #(1)  FF65(.out(TempSignI1_DFF), .in(TempSignI1), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF66(.out(TempSignQ1_DFF), .in(TempSignQ1), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF67(.out(TempSignI2_DFF), .in(TempSignI2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF68(.out(TempSignQ2_DFF), .in(TempSignQ2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF69(.out(TempSignI3_DFF), .in(TempSignI3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF70(.out(TempSignQ3_DFF), .in(TempSignQ3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF71(.out(TempSignI4_DFF), .in(TempSignI4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF72(.out(TempSignQ4_DFF), .in(TempSignQ4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));

// DFF #(1)  FF73(.out(TempSignI1_DFF2), .in(TempSignI1_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF74(.out(TempSignQ1_DFF2), .in(TempSignQ1_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF75(.out(TempSignI2_DFF2), .in(TempSignI2_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF76(.out(TempSignQ2_DFF2), .in(TempSignQ2_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF77(.out(TempSignI3_DFF2), .in(TempSignI3_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF78(.out(TempSignQ3_DFF2), .in(TempSignQ3_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF79(.out(TempSignI4_DFF2), .in(TempSignI4_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF80(.out(TempSignQ4_DFF2), .in(TempSignQ4_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));

// DFF #(1)  FF81(.out(TempSignI1_DFF3), .in(TempSignI1_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF82(.out(TempSignQ1_DFF3), .in(TempSignQ1_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF83(.out(TempSignI2_DFF3), .in(TempSignI2_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF84(.out(TempSignQ2_DFF3), .in(TempSignQ2_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF85(.out(TempSignI3_DFF3), .in(TempSignI3_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF86(.out(TempSignQ3_DFF3), .in(TempSignQ3_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF87(.out(TempSignI4_DFF3), .in(TempSignI4_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF88(.out(TempSignQ4_DFF3), .in(TempSignQ4_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));

// DFF #(1)  FF89(.out(TempSignI1_DFF4), .in(TempSignI1_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF90(.out(TempSignQ1_DFF4), .in(TempSignQ1_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF91(.out(TempSignI2_DFF4), .in(TempSignI2_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF92(.out(TempSignQ2_DFF4), .in(TempSignQ2_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF93(.out(TempSignI3_DFF4), .in(TempSignI3_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF94(.out(TempSignQ3_DFF4), .in(TempSignQ3_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF95(.out(TempSignI4_DFF4), .in(TempSignI4_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF96(.out(TempSignQ4_DFF4), .in(TempSignQ4_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));

// DFF #(1)  FF97(.out(TempSignI1_DFF5), .in(TempSignI1_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF98(.out(TempSignQ1_DFF5), .in(TempSignQ1_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF99(.out(TempSignI2_DFF5), .in(TempSignI2_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF100(.out(TempSignQ2_DFF5), .in(TempSignQ2_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF101(.out(TempSignI3_DFF5), .in(TempSignI3_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF102(.out(TempSignQ3_DFF5), .in(TempSignQ3_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF103(.out(TempSignI4_DFF5), .in(TempSignI4_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF104(.out(TempSignQ4_DFF5), .in(TempSignQ4_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));

// DFF #(1)  FF105(.out(TempSignI1_DFF6), .in(TempSignI1_DFF5), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF106(.out(TempSignQ1_DFF6), .in(TempSignQ1_DFF5), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF107(.out(TempSignI2_DFF6), .in(TempSignI2_DFF5), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF108(.out(TempSignQ2_DFF6), .in(TempSignQ2_DFF5), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF109(.out(TempSignI3_DFF6), .in(TempSignI3_DFF5), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF110(.out(TempSignQ3_DFF6), .in(TempSignQ3_DFF5), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF111(.out(TempSignI4_DFF6), .in(TempSignI4_DFF5), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF112(.out(TempSignQ4_DFF6), .in(TempSignQ4_DFF5), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));

// DFF #(1)  FF113(.out(TempSignI1_DFF7), .in(TempSignI1_DFF6), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF114(.out(TempSignQ1_DFF7), .in(TempSignQ1_DFF6), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF115(.out(TempSignI2_DFF7), .in(TempSignI2_DFF6), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF116(.out(TempSignQ2_DFF7), .in(TempSignQ2_DFF6), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF117(.out(TempSignI3_DFF7), .in(TempSignI3_DFF6), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF118(.out(TempSignQ3_DFF7), .in(TempSignQ3_DFF6), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF119(.out(TempSignI4_DFF7), .in(TempSignI4_DFF6), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF120(.out(TempSignQ4_DFF7), .in(TempSignQ4_DFF6), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));

// DFF #(1)  FF121(.out(TempSignI1_DFF8), .in(TempSignI1_DFF7), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF122(.out(TempSignQ1_DFF8), .in(TempSignQ1_DFF7), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF123(.out(TempSignI2_DFF8), .in(TempSignI2_DFF7), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF124(.out(TempSignQ2_DFF8), .in(TempSignQ2_DFF7), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF125(.out(TempSignI3_DFF8), .in(TempSignI3_DFF7), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF126(.out(TempSignQ3_DFF8), .in(TempSignQ3_DFF7), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF127(.out(TempSignI4_DFF8), .in(TempSignI4_DFF7), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF128(.out(TempSignQ4_DFF8), .in(TempSignQ4_DFF7), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// ////////////
// DFF #(1)  FF153(.out(TempSignI1_DFF9), .in(TempSignI1_DFF8), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF154(.out(TempSignQ1_DFF9), .in(TempSignQ1_DFF8), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF155(.out(TempSignI2_DFF9), .in(TempSignI2_DFF8), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF156(.out(TempSignQ2_DFF9), .in(TempSignQ2_DFF8), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF157(.out(TempSignI3_DFF9), .in(TempSignI3_DFF8), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF158(.out(TempSignQ3_DFF9), .in(TempSignQ3_DFF8), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF159(.out(TempSignI4_DFF9), .in(TempSignI4_DFF8), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF160(.out(TempSignQ4_DFF9), .in(TempSignQ4_DFF8), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));

// DFF #(1)  FF161(.out(TempSignI1_DFF10), .in(TempSignI1_DFF9), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF162(.out(TempSignQ1_DFF10), .in(TempSignQ1_DFF9), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF163(.out(TempSignI2_DFF10), .in(TempSignI2_DFF9), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF164(.out(TempSignQ2_DFF10), .in(TempSignQ2_DFF9), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF165(.out(TempSignI3_DFF10), .in(TempSignI3_DFF9), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF166(.out(TempSignQ3_DFF10), .in(TempSignQ3_DFF9), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF167(.out(TempSignI4_DFF10), .in(TempSignI4_DFF9), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF168(.out(TempSignQ4_DFF10), .in(TempSignQ4_DFF9), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));

// DFF #(1)  FF169(.out(TempSignI1_DFF11), .in(TempSignI1_DFF10), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF170(.out(TempSignQ1_DFF11), .in(TempSignQ1_DFF10), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF171(.out(TempSignI2_DFF11), .in(TempSignI2_DFF10), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF172(.out(TempSignQ2_DFF11), .in(TempSignQ2_DFF10), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF173(.out(TempSignI3_DFF11), .in(TempSignI3_DFF10), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF174(.out(TempSignQ3_DFF11), .in(TempSignQ3_DFF10), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF175(.out(TempSignI4_DFF11), .in(TempSignI4_DFF10), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF176(.out(TempSignQ4_DFF11), .in(TempSignQ4_DFF10), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));

// DFF #(1)  FF177(.out(TempSignI1_DFF12), .in(TempSignI1_DFF11), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF178(.out(TempSignQ1_DFF12), .in(TempSignQ1_DFF11), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF179(.out(TempSignI2_DFF12), .in(TempSignI2_DFF11), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF180(.out(TempSignQ2_DFF12), .in(TempSignQ2_DFF11), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF181(.out(TempSignI3_DFF12), .in(TempSignI3_DFF11), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF182(.out(TempSignQ3_DFF12), .in(TempSignQ3_DFF11), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF183(.out(TempSignI4_DFF12), .in(TempSignI4_DFF11), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF184(.out(TempSignQ4_DFF12), .in(TempSignQ4_DFF11), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// /////////////
// DFF #(1)  FF129(.out(SignI1), .in(TempSignI1_DFF12), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF130(.out(SignQ1), .in(TempSignQ1_DFF12), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF131(.out(SignI2), .in(TempSignI2_DFF12), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF132(.out(SignQ2), .in(TempSignQ2_DFF12), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF133(.out(SignI3), .in(TempSignI3_DFF12), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF134(.out(SignQ3), .in(TempSignQ3_DFF12), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF135(.out(SignI4), .in(TempSignI4_DFF12), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(1)  FF136(.out(SignQ4), .in(TempSignQ4_DFF12), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));

// Use 12 layers SRL + 1 layer FF（original 13 layers DFF）
InputBuffering_v2 #(1) BUFFER1(.Enable(Enable), .clk(ClockBFPQ), .DInputI(SignOutI1), .DInputQ(SignOutQ1), .TempRAMOutI(TempSignI1), .TempRAMOutQ(TempSignQ1), .BLOCK_SIZE(BLOCK_SIZE), .Counter(Counter));
InputBuffering_v2 #(1) BUFFER2(.Enable(Enable), .clk(ClockBFPQ), .DInputI(SignOutI2), .DInputQ(SignOutQ2), .TempRAMOutI(TempSignI2), .TempRAMOutQ(TempSignQ2), .BLOCK_SIZE(BLOCK_SIZE), .Counter(Counter));
InputBuffering_v2 #(1) BUFFER3(.Enable(Enable), .clk(ClockBFPQ), .DInputI(SignOutI3), .DInputQ(SignOutQ3), .TempRAMOutI(TempSignI3), .TempRAMOutQ(TempSignQ3), .BLOCK_SIZE(BLOCK_SIZE), .Counter(Counter));
InputBuffering_v2 #(1) BUFFER4(.Enable(Enable), .clk(ClockBFPQ), .DInputI(SignOutI4), .DInputQ(SignOutQ4), .TempRAMOutI(TempSignI4), .TempRAMOutQ(TempSignQ4), .BLOCK_SIZE(BLOCK_SIZE), .Counter(Counter));

// 12 layers SRL shift reg（No Reset）
always @(posedge ClockBFPQ) begin
    if (Enable) begin
        SignI1_srl <= {SignI1_srl[10:0], TempSignI1};
        SignQ1_srl <= {SignQ1_srl[10:0], TempSignQ1};
        SignI2_srl <= {SignI2_srl[10:0], TempSignI2};
        SignQ2_srl <= {SignQ2_srl[10:0], TempSignQ2};
        SignI3_srl <= {SignI3_srl[10:0], TempSignI3};
        SignQ3_srl <= {SignQ3_srl[10:0], TempSignQ3};
        SignI4_srl <= {SignI4_srl[10:0], TempSignI4};
        SignQ4_srl <= {SignQ4_srl[10:0], TempSignQ4};
    end
end

// Last FF（keep Asynchronized Reset）
DFF #(1) FF129(.out(SignI1), .in(SignI1_srl[11]), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(1) FF130(.out(SignQ1), .in(SignQ1_srl[11]), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(1) FF131(.out(SignI2), .in(SignI2_srl[11]), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(1) FF132(.out(SignQ2), .in(SignQ2_srl[11]), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(1) FF133(.out(SignI3), .in(SignI3_srl[11]), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(1) FF134(.out(SignQ3), .in(SignQ3_srl[11]), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(1) FF135(.out(SignI4), .in(SignI4_srl[11]), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(1) FF136(.out(SignQ4), .in(SignQ4_srl[11]), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
//////////////�NSign�T��������H�F��P��L��X�T���P�ɿ�X/////////////

//////////////Max module////////////
//Max MAX1(.InputI(InputI), .InputQ(InputQ), .clk(clk), .rst(rst), .counter(counter), .MaxValue(MaxValue));
Max_v3 MAX1(.InputI1(AbsI1), .InputQ1(AbsQ1), .InputI2(AbsI2), .InputQ2(AbsQ2), .InputI3(AbsI3), .InputQ3(AbsQ3), .InputI4(AbsI4), .InputQ4(AbsQ4), .clk(ClockBFPQ), .rst(clear), .Enable(Enable), .counter(Counter), .MaxValue_dff(MaxValue_DFF));
//////////////Max module////////////

//DFF #(13) FF9(.out(MaxValue_DFF), .in(MaxValue), .clk(ClockBFPQ), .Enable(EnableOr), .rst(rst));
//DFF #(13) FF3(.out(MaxValue_DFF2), .in(MaxValue_DFF), .clk(clk), .rst(rst));

////////////�N�T���PAlpha�ۭ�//////////
MultiplierTune MULtune(.in(MaxValue_DFF), .InverseAlpha(InverseAlpha), .out(Maxtune));
DFF #(14) FF10(.out(Maxtune_DFF), .in(Maxtune), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(14) FF11(.out(Maxtune_DFF2), .in(Maxtune_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
////////////�N�T���PAlpha�ۭ�//////////

////////////Eep. Judgement ��X�̤j�ȩҦb�����ƶ�///////////////
Exp EXP1(.in(Maxtune_DFF), .ThresholdExp1(ThresholdExp1), .ThresholdExp2(ThresholdExp2), .ThresholdExp3(ThresholdExp3), .ThresholdExp4(ThresholdExp4), .ThresholdExp5(ThresholdExp5), .ThresholdExp6(ThresholdExp6), .ThresholdExp7(ThresholdExp7), .Ce(TempCe));
// Ce Pipeline - SRL Opt.
// Original：10 layers DFF
// Modify to：3 front layers DFF（ because Quantizer need Ce_DFF3 data）+ 6 layers SRL + 1 layers FF
DFF #(3)  FF12(.out(Ce_DFF), .in(TempCe), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(3)  FF13(.out(Ce_DFF2), .in(Ce_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(3)  FF14(.out(Ce_DFF3), .in(Ce_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// 6 layers SRL (3-bit need 3 independent SRL）
always @(posedge ClockBFPQ) begin
    if (Enable) begin
        Ce_srl_0 <= {Ce_srl_0[4:0], Ce_DFF3[0]};
        Ce_srl_1 <= {Ce_srl_1[4:0], Ce_DFF3[1]};
        Ce_srl_2 <= {Ce_srl_2[4:0], Ce_DFF3[2]};
    end
end
// last FF（keep Asynchronized Reset ）
DFF #(3)  FF140(.out(Ce), .in({Ce_srl_2[5], Ce_srl_1[5], Ce_srl_0[5]}), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(3)  FF137(.out(Ce_DFF4), .in(Ce_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(3)  FF138(.out(Ce_DFF5), .in(Ce_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(3)  FF139(.out(Ce_DFF6), .in(Ce_DFF5), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(3)  FF147(.out(Ce_DFF7), .in(Ce_DFF6), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));//////
// DFF #(3)  FF148(.out(Ce_DFF8), .in(Ce_DFF7), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));///////
// DFF #(3)  FF149(.out(Ce_DFF9), .in(Ce_DFF8), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));/////////
// DFF #(3)  FF140(.out(Ce), .in(Ce_DFF9), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));//////////////9
////////////Eep. Judgement ��X�̤j�ȩҦb�����ƶ�///////////////

////////////Scaling Judgement ��X�̤j�ȩҦb��fractional exponent///////////////
//Scaling SCALE(.in(Maxtune_DFF2), .Ce(Ce_DFF), .A(A), .ThresholdW0(ThresholdW0), .ThresholdW1(ThresholdW1), .ThresholdW2(ThresholdW2), .ThresholdW3(ThresholdW3), .ThresholdW4(ThresholdW4), 
//				  .ThresholdW5(ThresholdW5), .ThresholdW6(ThresholdW6), .Cw(Cw));
Scaling_v2 SCALE(.in(Maxtune_DFF2), .FMOD(FMOD), .Ce(Ce_DFF), .A(A), .ThresholdW0(ThresholdW0), .ThresholdW1(ThresholdW1), .ThresholdW2(ThresholdW2), .ThresholdW3(ThresholdW3), .ThresholdW4(ThresholdW4), 
				  .ThresholdW5(ThresholdW5), .ThresholdW6(ThresholdW6), .clk(ClockBFPQ), .rst(clear), .Enable(Enable), .Cw(TempCw));					  			  

// Cw Pipeline - SRL 
// Original：9 layers DFF
// Modify to ：1st layer DFF（Because InverseWTable need Cw_DFF data）+ 7 layers SRL + 1級 FF
DFF #(3)  FF141(.out(Cw_DFF), .in(TempCw), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// 7 layers SRL （3-bit need 3 ondipandent SRL）
always @(posedge ClockBFPQ) begin
    if (Enable) begin
        Cw_srl_0 <= {Cw_srl_0[5:0], Cw_DFF[0]};
        Cw_srl_1 <= {Cw_srl_1[5:0], Cw_DFF[1]};
        Cw_srl_2 <= {Cw_srl_2[5:0], Cw_DFF[2]};
    end
end

// last FF（leep Asynchronized Reset）
DFF #(3)  FF146(.out(Cw), .in({Cw_srl_2[6], Cw_srl_1[6], Cw_srl_0[6]}), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(3)  FF142(.out(Cw_DFF2), .in(Cw_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(3)  FF143(.out(Cw_DFF3), .in(Cw_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(3)  FF144(.out(Cw_DFF4), .in(Cw_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(3)  FF145(.out(Cw_DFF5), .in(Cw_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(3)  FF150(.out(Cw_DFF6), .in(Cw_DFF5), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));//////////
// DFF #(3)  FF151(.out(Cw_DFF7), .in(Cw_DFF6), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));/////////
// DFF #(3)  FF152(.out(Cw_DFF8), .in(Cw_DFF7), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));////////////
// DFF #(3)  FF146(.out(Cw), .in(Cw_DFF8), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
////////////Scaling Judgement ��X�̤j�ȩҦb��fractional exponent///////////////

////////////�ھ�Cw��FMOD��X������Inverse scaling factor///////////////
InverseWTable IWT(.FMOD(FMOD), .Cw(Cw_DFF), .InvW(InvW));
////////////�ھ�Cw��FMOD��X������Inverse scaling factor///////////////

//InputBuffering BUFFERI(.clk(clk), .rst(rst), .in(InputI), .BMOD(BMOD), .out(TempRAMOutI));
//InputBuffering BUFFERQ(.clk(clk), .rst(rst), .in(InputQ), .BMOD(BMOD), .out(TempRAMOutQ));



////////////�Nabs��X�N�LBuffer/////////////
// InputBufferingMiddle BUFFER5(.Enable(Enable), .clk(ClockBFPQ), .rst(clear), .DInputI(AbsI1), .DInputQ(AbsQ1)/*, BLOCK_SIZE, Counter*/, .TempRAMOutI(TempRAMOutI1_DFF5), .TempRAMOutQ(TempRAMOutQ1_DFF5));
// InputBufferingMiddle BUFFER6(.Enable(Enable), .clk(ClockBFPQ), .rst(clear), .DInputI(AbsI2), .DInputQ(AbsQ2)/*, BLOCK_SIZE, Counter*/, .TempRAMOutI(TempRAMOutI2_DFF5), .TempRAMOutQ(TempRAMOutQ2_DFF5));
// InputBufferingMiddle BUFFER7(.Enable(Enable), .clk(ClockBFPQ), .rst(clear), .DInputI(AbsI3), .DInputQ(AbsQ3)/*, BLOCK_SIZE, Counter*/, .TempRAMOutI(TempRAMOutI3_DFF5), .TempRAMOutQ(TempRAMOutQ3_DFF5));
// InputBufferingMiddle BUFFER8(.Enable(Enable), .clk(ClockBFPQ), .rst(clear), .DInputI(AbsI4), .DInputQ(AbsQ4)/*, BLOCK_SIZE, Counter*/, .TempRAMOutI(TempRAMOutI4_DFF5), .TempRAMOutQ(TempRAMOutQ4_DFF5));
////////////�Nabs��X�N�LBuffer/////////////

InputBuffering_v2 #(13) BUFFER5(.Enable(Enable), .clk(ClockBFPQ)/*, .rst(rst)*/, .DInputI(AbsI1), .DInputQ(AbsQ1), .TempRAMOutI(TempRAMOutI1), .TempRAMOutQ(TempRAMOutQ1), .BLOCK_SIZE(BLOCK_SIZE), .Counter(Counter));
InputBuffering_v2 #(13) BUFFER6(.Enable(Enable), .clk(ClockBFPQ)/*, .rst(rst)*/, .DInputI(AbsI2), .DInputQ(AbsQ2), .TempRAMOutI(TempRAMOutI2), .TempRAMOutQ(TempRAMOutQ2), .BLOCK_SIZE(BLOCK_SIZE), .Counter(Counter));
InputBuffering_v2 #(13) BUFFER7(.Enable(Enable), .clk(ClockBFPQ)/*, .rst(rst)*/, .DInputI(AbsI3), .DInputQ(AbsQ3), .TempRAMOutI(TempRAMOutI3), .TempRAMOutQ(TempRAMOutQ3), .BLOCK_SIZE(BLOCK_SIZE), .Counter(Counter));
InputBuffering_v2 #(13) BUFFER8(.Enable(Enable), .clk(ClockBFPQ)/*, .rst(rst)*/, .DInputI(AbsI4), .DInputQ(AbsQ4), .TempRAMOutI(TempRAMOutI4), .TempRAMOutQ(TempRAMOutQ4), .BLOCK_SIZE(BLOCK_SIZE), .Counter(Counter));
// DFF #(13)  FF16(.out(TempRAMOutI1_DFF), .in(TempRAMOutI1), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF17(.out(TempRAMOutQ1_DFF), .in(TempRAMOutQ1), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF18(.out(TempRAMOutI2_DFF), .in(TempRAMOutI2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF19(.out(TempRAMOutQ2_DFF), .in(TempRAMOutQ2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF20(.out(TempRAMOutI3_DFF), .in(TempRAMOutI3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF21(.out(TempRAMOutQ3_DFF), .in(TempRAMOutQ3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF22(.out(TempRAMOutI4_DFF), .in(TempRAMOutI4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF23(.out(TempRAMOutQ4_DFF), .in(TempRAMOutQ4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));

// DFF #(13)  FF24(.out(TempRAMOutI1_DFF2), .in(TempRAMOutI1_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF25(.out(TempRAMOutQ1_DFF2), .in(TempRAMOutQ1_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF26(.out(TempRAMOutI2_DFF2), .in(TempRAMOutI2_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF27(.out(TempRAMOutQ2_DFF2), .in(TempRAMOutQ2_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF28(.out(TempRAMOutI3_DFF2), .in(TempRAMOutI3_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF29(.out(TempRAMOutQ3_DFF2), .in(TempRAMOutQ3_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF30(.out(TempRAMOutI4_DFF2), .in(TempRAMOutI4_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF31(.out(TempRAMOutQ4_DFF2), .in(TempRAMOutQ4_DFF), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));

// DFF #(13)  FF32(.out(TempRAMOutI1_DFF3), .in(TempRAMOutI1_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF33(.out(TempRAMOutQ1_DFF3), .in(TempRAMOutQ1_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF34(.out(TempRAMOutI2_DFF3), .in(TempRAMOutI2_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF35(.out(TempRAMOutQ2_DFF3), .in(TempRAMOutQ2_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF36(.out(TempRAMOutI3_DFF3), .in(TempRAMOutI3_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF37(.out(TempRAMOutQ3_DFF3), .in(TempRAMOutQ3_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF38(.out(TempRAMOutI4_DFF3), .in(TempRAMOutI4_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF39(.out(TempRAMOutQ4_DFF3), .in(TempRAMOutQ4_DFF2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));

// DFF #(13)  FF40(.out(TempRAMOutI1_DFF4), .in(TempRAMOutI1_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF41(.out(TempRAMOutQ1_DFF4), .in(TempRAMOutQ1_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF42(.out(TempRAMOutI2_DFF4), .in(TempRAMOutI2_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF43(.out(TempRAMOutQ2_DFF4), .in(TempRAMOutQ2_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF44(.out(TempRAMOutI3_DFF4), .in(TempRAMOutI3_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF45(.out(TempRAMOutQ3_DFF4), .in(TempRAMOutQ3_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF46(.out(TempRAMOutI4_DFF4), .in(TempRAMOutI4_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF47(.out(TempRAMOutQ4_DFF4), .in(TempRAMOutQ4_DFF3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
////
// DFF #(13)  FF64(.out(TempRAMOutI1_DFF5), .in(TempRAMOutI1_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF265(.out(TempRAMOutQ1_DFF5), .in(TempRAMOutQ1_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF266(.out(TempRAMOutI2_DFF5), .in(TempRAMOutI2_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF267(.out(TempRAMOutQ2_DFF5), .in(TempRAMOutQ2_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF268(.out(TempRAMOutI3_DFF5), .in(TempRAMOutI3_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF269(.out(TempRAMOutQ3_DFF5), .in(TempRAMOutQ3_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF270(.out(TempRAMOutI4_DFF5), .in(TempRAMOutI4_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
// DFF #(13)  FF271(.out(TempRAMOutQ4_DFF5), .in(TempRAMOutQ4_DFF4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));

// TempRAMOut Pipeline - SRL Opt
// Original：5 layers DFF × 8ch × 13-bit = 520 FF
// Modify to：4 layers SRL + 1 layers FF
integer i;
always @(posedge ClockBFPQ) begin
    if (Enable) begin
        for (i = 0; i < 13; i = i + 1) begin
            RAMOutI1_srl[i] <= {RAMOutI1_srl[i][2:0], TempRAMOutI1[i]};
            RAMOutQ1_srl[i] <= {RAMOutQ1_srl[i][2:0], TempRAMOutQ1[i]};
            RAMOutI2_srl[i] <= {RAMOutI2_srl[i][2:0], TempRAMOutI2[i]};
            RAMOutQ2_srl[i] <= {RAMOutQ2_srl[i][2:0], TempRAMOutQ2[i]};
            RAMOutI3_srl[i] <= {RAMOutI3_srl[i][2:0], TempRAMOutI3[i]};
            RAMOutQ3_srl[i] <= {RAMOutQ3_srl[i][2:0], TempRAMOutQ3[i]};
            RAMOutI4_srl[i] <= {RAMOutI4_srl[i][2:0], TempRAMOutI4[i]};
            RAMOutQ4_srl[i] <= {RAMOutQ4_srl[i][2:0], TempRAMOutQ4[i]};
        end
    end
end

// Combine SRL to 13-bit vector
wire [12:0] RAMOutI1_srl_out, RAMOutQ1_srl_out, RAMOutI2_srl_out, RAMOutQ2_srl_out;
wire [12:0] RAMOutI3_srl_out, RAMOutQ3_srl_out, RAMOutI4_srl_out, RAMOutQ4_srl_out;

genvar j;
generate
    for (j = 0; j < 13; j = j + 1) begin : gen_srl_out
        assign RAMOutI1_srl_out[j] = RAMOutI1_srl[j][3];
        assign RAMOutQ1_srl_out[j] = RAMOutQ1_srl[j][3];
        assign RAMOutI2_srl_out[j] = RAMOutI2_srl[j][3];
        assign RAMOutQ2_srl_out[j] = RAMOutQ2_srl[j][3];
        assign RAMOutI3_srl_out[j] = RAMOutI3_srl[j][3];
        assign RAMOutQ3_srl_out[j] = RAMOutQ3_srl[j][3];
        assign RAMOutI4_srl_out[j] = RAMOutI4_srl[j][3];
        assign RAMOutQ4_srl_out[j] = RAMOutQ4_srl[j][3];
    end
endgenerate
// Last FF（keep Asynchronized Reset，and bfpq_Multiplier need datas）
DFF #(13)  FF64(.out(TempRAMOutI1_DFF5), .in(RAMOutI1_srl_out), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(13)  FF265(.out(TempRAMOutQ1_DFF5), .in(RAMOutQ1_srl_out), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(13)  FF266(.out(TempRAMOutI2_DFF5), .in(RAMOutI2_srl_out), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(13)  FF267(.out(TempRAMOutQ2_DFF5), .in(RAMOutQ2_srl_out), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(13)  FF268(.out(TempRAMOutI3_DFF5), .in(RAMOutI3_srl_out), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(13)  FF269(.out(TempRAMOutQ3_DFF5), .in(RAMOutQ3_srl_out), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(13)  FF270(.out(TempRAMOutI4_DFF5), .in(RAMOutI4_srl_out), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(13)  FF271(.out(TempRAMOutQ4_DFF5), .in(RAMOutQ4_srl_out), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
//////

//InputBuffering BUFFERI(.clk(clk), .rst(rst), .in(AbsI), .BMOD(BMOD), .out(TempRAMOutI));
//InputBuffering BUFFERQ(.clk(clk), .rst(rst), .in(AbsQ), .BMOD(BMOD), .out(TempRAMOutQ));

//Abs Abs1(.in(TempRAMOutI), .out(AbsI));
//Abs Abs2(.in(TempRAMOutQ), .out(AbsQ));

//SandA #(14,17) SA2I(.index(VarianceSelect), .in(AbsI), .out(SAOUT2I));
//SandA #(14,17) SA2Q(.index(VarianceSelect), .in(AbsQ), .out(SAOUT2Q)); 
//SandA #(14,17) SA2I(.index(VarianceSelect_DFF), .in(TempRAMOutI_DFF), .out(SAOUT2I));
//SandA #(14,17) SA2Q(.index(VarianceSelect_DFF), .in(TempRAMOutQ_DFF), .out(SAOUT2Q)); 
//
//DFF #(17)  FF11(.out(SAOUT2I_DFF), .in(SAOUT2I), .clk(clk), .rst(rst));
//DFF #(17)  FF12(.out(SAOUT2I_DFF2), .in(SAOUT2I_DFF), .clk(clk), .rst(rst));
//DFF #(17)  FF13(.out(SAOUT2I_DFF3), .in(SAOUT2I_DFF2), .clk(clk), .rst(rst));
//DFF #(17)  FF17(.out(SAOUT2I_DFF4), .in(SAOUT2I_DFF3), .clk(clk), .rst(rst));
//DFF #(17)  FF23(.out(SAOUT2I_DFF5), .in(SAOUT2I_DFF4), .clk(clk), .rst(rst));
//DFF #(17)  FF14(.out(SAOUT2Q_DFF), .in(SAOUT2Q), .clk(clk), .rst(rst));
//DFF #(17)  FF15(.out(SAOUT2Q_DFF2), .in(SAOUT2Q_DFF), .clk(clk), .rst(rst));
//DFF #(17)  FF16(.out(SAOUT2Q_DFF3), .in(SAOUT2Q_DFF2), .clk(clk), .rst(rst));
//DFF #(17)  FF18(.out(SAOUT2Q_DFF4), .in(SAOUT2Q_DFF3), .clk(clk), .rst(rst));
//DFF #(17)  FF24(.out(SAOUT2Q_DFF5), .in(SAOUT2Q_DFF4), .clk(clk), .rst(rst));

//////////�NBuffer�L���T�����WInverse Scaling factor//////////////
bfpq_Multiplier MULI1(.in(TempRAMOutI1_DFF5), .InvW(InvW), .out(DataMulScalingI1));///
bfpq_Multiplier MULQ1(.in(TempRAMOutQ1_DFF5), .InvW(InvW), .out(DataMulScalingQ1));/////
bfpq_Multiplier MULI2(.in(TempRAMOutI2_DFF5), .InvW(InvW), .out(DataMulScalingI2));///////
bfpq_Multiplier MULQ2(.in(TempRAMOutQ2_DFF5), .InvW(InvW), .out(DataMulScalingQ2));//////
bfpq_Multiplier MULI3(.in(TempRAMOutI3_DFF5), .InvW(InvW), .out(DataMulScalingI3));//////
bfpq_Multiplier MULQ3(.in(TempRAMOutQ3_DFF5), .InvW(InvW), .out(DataMulScalingQ3));//////
bfpq_Multiplier MULI4(.in(TempRAMOutI4_DFF5), .InvW(InvW), .out(DataMulScalingI4));/////
bfpq_Multiplier MULQ4(.in(TempRAMOutQ4_DFF5), .InvW(InvW), .out(DataMulScalingQ4));/////


DFF #(18)  FF48(.out(DataMulScalingI1_DFF), .in(DataMulScalingI1), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(18)  FF49(.out(DataMulScalingQ1_DFF), .in(DataMulScalingQ1), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(18)  FF50(.out(DataMulScalingI2_DFF), .in(DataMulScalingI2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(18)  FF51(.out(DataMulScalingQ2_DFF), .in(DataMulScalingQ2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(18)  FF52(.out(DataMulScalingI3_DFF), .in(DataMulScalingI3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(18)  FF53(.out(DataMulScalingQ3_DFF), .in(DataMulScalingQ3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(18)  FF54(.out(DataMulScalingI4_DFF), .in(DataMulScalingI4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(18)  FF55(.out(DataMulScalingQ4_DFF), .in(DataMulScalingQ4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
//////////�NBuffer�L���T�����WInverse Scaling factor//////////////


//////////�N�T�����q��////////////
Quantizer_v4 QTI1(.clk(ClockBFPQ), .rst(clear), .Enable(Enable), .in(DataMulScalingI1_DFF), .MMOD(MMOD_DFF), .Ce(Ce_DFF3), .out(Iout1));
Quantizer_v4 QTQ1(.clk(ClockBFPQ), .rst(clear), .Enable(Enable), .in(DataMulScalingQ1_DFF), .MMOD(MMOD_DFF), .Ce(Ce_DFF3), .out(Qout1));
Quantizer_v4 QTI2(.clk(ClockBFPQ), .rst(clear), .Enable(Enable), .in(DataMulScalingI2_DFF), .MMOD(MMOD_DFF), .Ce(Ce_DFF3), .out(Iout2));
Quantizer_v4 QTQ2(.clk(ClockBFPQ), .rst(clear), .Enable(Enable), .in(DataMulScalingQ2_DFF), .MMOD(MMOD_DFF), .Ce(Ce_DFF3), .out(Qout2));
Quantizer_v4 QTI3(.clk(ClockBFPQ), .rst(clear), .Enable(Enable), .in(DataMulScalingI3_DFF), .MMOD(MMOD_DFF), .Ce(Ce_DFF3), .out(Iout3));
Quantizer_v4 QTQ3(.clk(ClockBFPQ), .rst(clear), .Enable(Enable), .in(DataMulScalingQ3_DFF), .MMOD(MMOD_DFF), .Ce(Ce_DFF3), .out(Qout3));
Quantizer_v4 QTI4(.clk(ClockBFPQ), .rst(clear), .Enable(Enable), .in(DataMulScalingI4_DFF), .MMOD(MMOD_DFF), .Ce(Ce_DFF3), .out(Iout4));
Quantizer_v4 QTQ4(.clk(ClockBFPQ), .rst(clear), .Enable(Enable), .in(DataMulScalingQ4_DFF), .MMOD(MMOD_DFF), .Ce(Ce_DFF3), .out(Qout4));


DFF #(7)  FF56(.out(MantissaI1), .in(Iout1), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(7)  FF57(.out(MantissaQ1), .in(Qout1), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(7)  FF58(.out(MantissaI2), .in(Iout2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(7)  FF59(.out(MantissaQ2), .in(Qout2), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));	
DFF #(7)  FF60(.out(MantissaI3), .in(Iout3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(7)  FF61(.out(MantissaQ3), .in(Qout3), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));	
DFF #(7)  FF62(.out(MantissaI4), .in(Iout4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));
DFF #(7)  FF63(.out(MantissaQ4), .in(Qout4), .clk(ClockBFPQ), .Enable(Enable), .rst(clear));		
//////////�N�T�����q��////////////
		

endmodule


