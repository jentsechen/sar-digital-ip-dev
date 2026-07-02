module bfpq_SingleFF(Enable,Rst,DInput,QOutput,Clock);

parameter SFF_Wordlength = 14;
input Enable;
input Rst,Clock;
input  signed[SFF_Wordlength-1:0]DInput;
output reg signed[SFF_Wordlength-1:0]QOutput;

always @(posedge Clock or posedge Rst)begin

if(Rst)
begin
	
QOutput<=13'b0;


end
else if(Enable)
begin 

QOutput<= DInput;


end

else 
QOutput<=QOutput;

end

endmodule 