`timescale 1ns / 1ns

module baq_disram_rtl_common_clk #(
    // configurable 
    parameter LOG2_MEM_DEPTH = 10,
    parameter MEM_WIDTH = 14
    // parameter MEM_WIDTH = 32
) (
    input clk,
    input rst,

    // higher priority
	input disram_a_en,                                             // Chip Enable Signal (optional)
	output reg [MEM_WIDTH-1:0] disram_a_dout,                      // Data Out Bus (optional)
	input [MEM_WIDTH-1:0] disram_a_din,                            // Data In Bus (optional)
	input disram_a_wen,                                            // Word Enables (optional)
	input [LOG2_MEM_DEPTH-1:0] disram_a_addr,                      // Address Signal (required)

    // lower priority
	input disram_b_en,                                             // Chip Enable Signal (optional)
	output reg [MEM_WIDTH-1:0] disram_b_dout,                      // Data Out Bus (optional)
	input [MEM_WIDTH-1:0] disram_b_din,                            // Data In Bus (optional)
	input disram_b_wen,                                            // Word Enables (optional)
	input [LOG2_MEM_DEPTH-1:0] disram_b_addr // Address Signal (required)
);
// not configurable 
localparam MEM_DEPTH = (1 << LOG2_MEM_DEPTH);
// localparam BYTE_WIDTH = (MEM_WIDTH/8);
// localparam ADDR_WIDTH = LOG2_MEM_DEPTH + $clog2(BYTE_WIDTH); 

reg [MEM_WIDTH-1:0] mem [0:MEM_DEPTH-1];

integer i;

always@(posedge clk)begin
    if(rst) begin
        disram_a_dout <= 0;
        disram_b_dout <= 0;
    end else begin
        if(disram_a_en) disram_a_dout <= mem[disram_a_addr];
        if(disram_b_en) disram_b_dout <= mem[disram_b_addr];
        if(disram_a_en) begin
            if(disram_a_wen) begin
                mem[disram_a_addr] <= disram_a_din;
            end
        end else if(disram_b_en) begin
            if(disram_b_wen) begin
                mem[disram_b_addr] <= disram_b_din;
            end
        end
    end
end


endmodule
