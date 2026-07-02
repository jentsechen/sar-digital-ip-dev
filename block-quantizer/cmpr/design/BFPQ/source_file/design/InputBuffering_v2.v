module InputBuffering_v2(Enable, clk/*, rst*/, DInputI, DInputQ, BLOCK_SIZE, Counter, TempRAMOutI, TempRAMOutQ);

//parameter ADC_WORDLENGTH = 4'd14;
parameter  wordlength=4'd13;
//input clk,Clock,rst;
input clk/*,rst*/;


input Enable;

input [2:0]BLOCK_SIZE;

input [wordlength-1:0]DInputI,DInputQ;

output [wordlength-1:0]TempRAMOutI,TempRAMOutQ;

input [2:0] Counter;

//parameter BLOCK_SIZE=6'd32;


wire [2:0]WA;////write address

reg WE,RE;////write & read enable

reg [2:0]RA;////read address

//reg [2:0]Counter;

// Counter 
//always@(posedge clk or posedge rst)begin 
//if(rst == 1'b1)
//Counter <= BLOCK_SIZE-2'd1;
//else if(Enable)begin
//if (Counter == BLOCK_SIZE)
//Counter <= 3'b0;
//else 
//Counter <= Counter + 1'b1;
//end
//
//else
//Counter <= Counter;
//end
 
//SRAM Signal Control
assign WA=Counter;


always@(*)begin
if(Counter == BLOCK_SIZE)
RA = 3'b0;
else
RA = Counter +1'b1;
end


//always@(posedge clk or posedge rst)begin
//if(rst)
//WE <= 1'b0;
//else if(!Enable)
//WE <= 1'b0;
//else
//WE <= 1'b1;
//end
//
//
//always@(posedge clk or posedge rst)begin
//if(rst)
//RE <= 1'b0;
//else
//RE <= 1'b1;
//end

// SRAM
SRAM #(wordlength) SI0(.Clock(clk), .Enable(Enable), /*.WE(WE),.RE(RE),*/.WA(WA),.RA(RA),.DataIn(DInputI),.DataOut(TempRAMOutI));
//SRAM SI1(.Clock(clk),.WE(WE),.RE(RE),.WA(WA),.RA(RA),.DataIn(DInputI2),.DataOut(TempRAMOutI2));
//SRAM SI2(.Clock(clk),.WE(WE),.RE(RE),.WA(WA),.RA(RA),.DataIn(DInputI3),.DataOut(TempRAMOutI3));
//SRAM SI3(.Clock(clk),.WE(WE),.RE(RE),.WA(WA),.RA(RA),.DataIn(DInputI4),.DataOut(TempRAMOutI4));

SRAM #(wordlength) SQ0(.Clock(clk), .Enable(Enable), /*.WE(WE),.RE(RE),*/.WA(WA),.RA(RA),.DataIn(DInputQ),.DataOut(TempRAMOutQ));
//SRAM SQ1(.Clock(clk),.WE(WE),.RE(RE),.WA(WA),.RA(RA),.DataIn(DInputQ2),.DataOut(TempRAMOutQ2));
//SRAM SQ2(.Clock(clk),.WE(WE),.RE(RE),.WA(WA),.RA(RA),.DataIn(DInputQ3),.DataOut(TempRAMOutQ3));
//SRAM SQ3(.Clock(clk),.WE(WE),.RE(RE),.WA(WA),.RA(RA),.DataIn(DInputQ4),.DataOut(TempRAMOutQ4));



endmodule 