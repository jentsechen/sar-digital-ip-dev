module SRAM(Clock,Enable, /*WE,RE,*/WA,RA,DataIn,DataOut);

//parameter ADC_WORDLENGTH = 4'd14;
parameter  wordlength=4'd13;
parameter BLOCK_SIZE = 3'd7;
parameter Addresswordlength = 2'd2;

input Clock,/*WE,RE,*/ Enable;
input [Addresswordlength:0]WA,RA;

input [wordlength-1:0]DataIn;
output reg [wordlength-1:0]DataOut;

reg [wordlength-1:0]Memory[0:BLOCK_SIZE];

 always@(posedge Clock)begin
 if (Enable)

		Memory[WA]<=DataIn;

 else
	Memory[WA]<=Memory[WA];

  end
 
 always @(posedge Clock)begin
 if (Enable) 

DataOut<=Memory[RA];

else 
DataOut<=DataOut;
end

endmodule 