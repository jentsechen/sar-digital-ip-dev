module SingleFF#(
//-----------parameter-----------------------------
    parameter SFF_Wordlength = 14
)(
//-----------input/output ports--------------------
input Enable,
input rst,
input clk,
input  signed[SFF_Wordlength-1:0]DInput,
output reg signed[SFF_Wordlength-1:0]QOutput
);
//-----------wire/reg------------------------------
//-----------function------------------------------
always @(posedge clk or posedge rst)begin
    if(rst)        QOutput <= 0;
    else begin
        if(Enable) QOutput <= DInput;
        else       QOutput <= QOutput;
    end
end
endmodule 