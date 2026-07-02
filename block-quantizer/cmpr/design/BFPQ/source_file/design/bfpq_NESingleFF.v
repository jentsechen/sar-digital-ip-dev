module bfpq_NESingleFF(Rst,DInput,QOutput,Clock);

parameter SFF_Wordlength = 14;

input Rst,Clock;
input  signed[SFF_Wordlength-1:0]DInput;
output reg signed[SFF_Wordlength-1:0]QOutput;

always @(posedge Clock or posedge Rst)begin

if(Rst)
begin
	
QOutput<=0;


end
else 
begin 

QOutput<= DInput;


end


end

endmodule 