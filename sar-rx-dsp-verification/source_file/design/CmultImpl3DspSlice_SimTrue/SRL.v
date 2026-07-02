
    module SRL #(
    parameter DATA_WIDTH=32,
    parameter DEPTH=6,
    parameter LOG2_DEPTH = 2
)(
    input clk                   ,
    input en                    ,
    
    input [DATA_WIDTH-1:0] D    ,
    input [LOG2_DEPTH-1:0] A ,
    output [DATA_WIDTH-1:0] Q
);
genvar bit_index;
generate
    for(bit_index=0; bit_index<DATA_WIDTH; bit_index=bit_index+1) begin
        SRL_delay_line #(
            .DEPTH(DEPTH),
        	.ADDR_W(LOG2_DEPTH)
        )
        shift_reg(
        	.clk(clk), 
            .en(en),
        	.D(D[bit_index]),
        	.A(A),
        	.Q(Q[bit_index])
        );
    end
endgenerate
endmodule

module SRL_delay_line#( //D->Q: A+2 clocks delay
    parameter DEPTH = 256,
	parameter ADDR_W = 8
)(
	input clk, 
	input D,
	input en,
	input [ADDR_W-1:0] A,
	output Q
);
(* shreg_extract = "yes"*) reg [DEPTH-1:0] shift_reg;
always @(posedge clk) begin
	if(en) shift_reg <= {shift_reg, D};
end
assign Q = shift_reg[A];
endmodule

  