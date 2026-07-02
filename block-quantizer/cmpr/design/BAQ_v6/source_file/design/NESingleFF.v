module NESingleFF #(
//-----------parameter-----------------------------
    parameter SFF_Wordlength = 14
)(
//-----------input/output ports--------------------
input rst,
input clk,
input  signed[SFF_Wordlength-1:0]DInput,
output reg signed[SFF_Wordlength-1:0]QOutput
);
//-----------wire/reg------------------------------
//-----------function------------------------------
always @(posedge clk or posedge rst)begin
    if(rst) QOutput<=0;
    else    QOutput<= DInput;
end
endmodule 