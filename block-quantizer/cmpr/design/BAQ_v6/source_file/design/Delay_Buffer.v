`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2023 01:27:58 PM
// Design Name: 
// Module Name: Delay_Buffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module Delay_Buffer #(
//-----------parameter-----------------------------
parameter PARALLEL_NUMBER = 4,
parameter ADC_WORDLENGTH = 14,
parameter BLOCKSIZEMOD_WRODLENGTH = 2,
parameter PARALLEL_BLOCK_SIZE_WORDLENGTH = 8,
parameter VALIDCOUNTER_WORDLENGTH = 8,        //Counter for valid output

localparam PARALLEL_BLOCK128 = 128/PARALLEL_NUMBER,
localparam PARALLEL_BLOCK256 = 256/PARALLEL_NUMBER,
localparam PARALLEL_BLOCK512 = 512/PARALLEL_NUMBER,
localparam THE_NUM_OF_PIPELINE = 5,
localparam fOutValid_cnt = 4+$clog2(2*PARALLEL_NUMBER)+1+8
)(
//-----------input/output ports--------------------
input clk,
input rst,
input enable,
input[BLOCKSIZEMOD_WRODLENGTH-1:0]BSMOD,
input[ADC_WORDLENGTH*PARALLEL_NUMBER-1:0]DataInI_seq,
input[ADC_WORDLENGTH*PARALLEL_NUMBER-1:0]DataInQ_seq,

output reg[PARALLEL_BLOCK_SIZE_WORDLENGTH-1:0]counter,
output fOutValid,
output reg fBlockEnd,
output[ADC_WORDLENGTH*PARALLEL_NUMBER-1:0]DataOutI_seq,
output[ADC_WORDLENGTH*PARALLEL_NUMBER-1:0]DataOutQ_seq
);

//-----------wire/reg------------------------------
wire[PARALLEL_BLOCK_SIZE_WORDLENGTH-1:0]WA;
wire WE;

wire[ADC_WORDLENGTH-1:0]DataInI_set[0:PARALLEL_NUMBER-1];
wire[ADC_WORDLENGTH-1:0]DataInQ_set[0:PARALLEL_NUMBER-1];

wire[ADC_WORDLENGTH-1:0]DataOutI_set[0:PARALLEL_NUMBER-1];
wire[ADC_WORDLENGTH-1:0]DataOutQ_set[0:PARALLEL_NUMBER-1];

reg[PARALLEL_BLOCK_SIZE_WORDLENGTH-1:0]block_size;
reg RE;
reg [PARALLEL_BLOCK_SIZE_WORDLENGTH-1:0]RA;
reg OneRound;
reg temp_fOutValid;

genvar gen_i;
//-----------function------------------------------
generate
    for (gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1) begin
        assign DataInI_set[gen_i] = DataInI_seq[ADC_WORDLENGTH*gen_i +: ADC_WORDLENGTH];
        assign DataInQ_set[gen_i] = DataInQ_seq[ADC_WORDLENGTH*gen_i +: ADC_WORDLENGTH];

        assign DataOutI_seq[ADC_WORDLENGTH*gen_i +: ADC_WORDLENGTH] = DataOutI_set[gen_i];
        assign DataOutQ_seq[ADC_WORDLENGTH*gen_i +: ADC_WORDLENGTH] = DataOutQ_set[gen_i];
    end
endgenerate
always @* begin
    case(BSMOD)
        2'd0: block_size = PARALLEL_BLOCK128-1;
        2'd1: block_size = PARALLEL_BLOCK256-1;
        2'd2: block_size = PARALLEL_BLOCK512-1;
     default: block_size = 1'b0;
    endcase
end
//data control
always @(posedge clk or posedge rst)begin
    if(rst)                       counter <= 1'b0;
    else if(enable) begin
        if(counter == block_size) counter <= 1'b0;
        else                      counter <= counter + 1'b1;
    end
    else                          counter <= counter;
end
//Read, write control
always @(posedge clk or posedge rst)begin
    if(rst) RE <= 1'b0;
    else    RE <= 1'b1;
end
assign WE = enable;
assign WA = counter;
always@* begin 
    if(enable) begin
	    if(counter == block_size) RA = 8'b0;
        else                      RA = counter +1'b1;
	end
	else                          RA = counter;
end

//Data storage
generate
    for (gen_i=0;gen_i<PARALLEL_NUMBER;gen_i=gen_i+1) begin
        baq_disram_rtl_common_clk#(.MEM_WIDTH(ADC_WORDLENGTH),.LOG2_MEM_DEPTH(PARALLEL_BLOCK_SIZE_WORDLENGTH))
            DSI(.clk(clk),.rst(rst),
                .disram_a_en(enable)                         ,.disram_a_din(DataInI_set[gen_i]),.disram_a_wen(enable),.disram_a_addr(WA),
                .disram_b_en(RE),    .disram_b_dout(DataOutI_set[gen_i]),                                             .disram_b_addr(RA));
        baq_disram_rtl_common_clk#(.MEM_WIDTH(ADC_WORDLENGTH),.LOG2_MEM_DEPTH(PARALLEL_BLOCK_SIZE_WORDLENGTH))
            DSQ(.clk(clk),.rst(rst),
                .disram_a_en(enable)                         ,.disram_a_din(DataInQ_set[gen_i]),.disram_a_wen(enable),.disram_a_addr(WA),
                .disram_b_en(RE),    .disram_b_dout(DataOutQ_set[gen_i]),                                             .disram_b_addr(RA));
    end
endgenerate
//BAQ output control
always @(posedge clk or posedge rst)begin
    if(rst)                           OneRound <= 1'b0;
    else begin 
        if(enable) begin
            if(counter == block_size) OneRound <= 1'b1;
            else                      OneRound <= OneRound;
        end
        else                          OneRound <= OneRound;
    end
end
always @(posedge clk or posedge rst) begin
    if(rst)                        temp_fOutValid <= 1'b0;
    else begin
        if(OneRound&(counter==fOutValid_cnt)) begin
            if (enable) temp_fOutValid <= 1'b1;           //pipeline -> RAMOUT(7 or 8),Multiplier(1),OUTPUT(8) 
            else temp_fOutValid <= temp_fOutValid;
        end else temp_fOutValid <= temp_fOutValid;
    end
end
assign fOutValid = temp_fOutValid & enable;

always @(posedge clk or posedge rst) begin
    if(rst)                             fBlockEnd <= 1'b0;
    else begin
        if(enable) begin
            if(fOutValid&(counter==(fOutValid_cnt-1))) fBlockEnd <= 1'b1;
            else                        fBlockEnd <= 1'b0;
        end
        else                            fBlockEnd <= fBlockEnd;
    end
end

endmodule











