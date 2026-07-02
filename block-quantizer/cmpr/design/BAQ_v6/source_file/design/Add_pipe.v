module Add_pipe #(
    parameter ACC_WORDLENGTH = 29,
    parameter ADD_TOTAL_STAGE = 3,
    parameter ADD_STAGE_NUMBER = 1,
    localparam ADD_IN_NUMBER = (2**(ADD_TOTAL_STAGE-ADD_STAGE_NUMBER+1)),
    localparam ADD_IN_WORDLENGTH = ACC_WORDLENGTH*ADD_IN_NUMBER,
    localparam ADD_OUT_NUMBER = (2**(ADD_TOTAL_STAGE-ADD_STAGE_NUMBER)),
    localparam ADD_OUT_WORDLENGTH = ACC_WORDLENGTH*ADD_OUT_NUMBER
) (
input [ADD_IN_WORDLENGTH-1:0]in1,
output [ADD_OUT_WORDLENGTH-1:0] out1
);
//-------------------------------------------------------------
wire [ACC_WORDLENGTH-1:0]in1_set[0:ADD_IN_NUMBER-1];
reg [ACC_WORDLENGTH-1:0]out1_set[0:ADD_OUT_NUMBER-1];
genvar gen_i;
integer i;
//-------------------------------------------------------------
generate
    for (gen_i=0;gen_i<ADD_IN_NUMBER;gen_i=gen_i+1) begin
        assign in1_set[gen_i] = in1[ACC_WORDLENGTH*gen_i +: ACC_WORDLENGTH];
    end
    for (gen_i=0;gen_i<ADD_OUT_NUMBER;gen_i=gen_i+1) begin
        assign out1[ACC_WORDLENGTH*gen_i +: ACC_WORDLENGTH] = out1_set[gen_i];
    end
endgenerate
always @(*) begin
    for (i=0;i<ADD_OUT_NUMBER;i=i+1) begin
        out1_set[i] = in1_set[2*i] + in1_set[2*i+1];
    end
end
endmodule