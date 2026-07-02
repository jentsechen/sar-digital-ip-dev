
    module bram_rtl #(
    // configurable 
    parameter LOG2_MEM_DEPTH = 10,
    parameter MEM_WIDTH = 32
) (
    (* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL,MEM_ECC NONE,READ_WRITE_MODE READ_WRITE" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_A EN" *) 	 input bram_a_en, // Chip Enable Signal (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_A DOUT" *) output reg [MEM_WIDTH-1:0] bram_a_dout, // Data Out Bus (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_A DIN" *)  input [MEM_WIDTH-1:0] bram_a_din, // Data In Bus (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_A WE" *) 	 input [(MEM_WIDTH/8)-1:0] bram_a_wen, // Byte Enables (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_A ADDR" *) input [LOG2_MEM_DEPTH + $clog2(MEM_WIDTH/8)-1:0] bram_a_addr, // Address Signal (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_A CLK" *)  input bram_a_clk, // Clock Signal (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_A RST" *)  input bram_a_rst, // Reset Signal (required)

    (* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL,MEM_ECC NONE,READ_WRITE_MODE READ_WRITE" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_B EN" *) 	 input bram_b_en, // Chip Enable Signal (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_B DOUT" *) output reg [MEM_WIDTH-1:0] bram_b_dout, // Data Out Bus (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_B DIN" *)  input [MEM_WIDTH-1:0] bram_b_din, // Data In Bus (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_B WE" *) 	 input [(MEM_WIDTH/8)-1:0] bram_b_wen, // Byte Enables (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_B ADDR" *) input [LOG2_MEM_DEPTH + $clog2(MEM_WIDTH/8)-1:0] bram_b_addr, // Address Signal (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_B CLK" *)  input bram_b_clk, // Clock Signal (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_B RST" *)  input bram_b_rst // Reset Signal (required)
);
// not configurable 
localparam MEM_DEPTH = (1 << LOG2_MEM_DEPTH);
localparam BYTE_WIDTH = (MEM_WIDTH/8);
localparam ADDR_WIDTH = LOG2_MEM_DEPTH + $clog2(BYTE_WIDTH); 

(* ram_style = "block" *) reg [MEM_WIDTH-1:0] mem [0:MEM_DEPTH-1];
integer i;

always@(posedge bram_a_clk)begin
    if(bram_a_rst) begin
        bram_a_dout <= 0;
    end else begin
        if(bram_a_en) begin
            bram_a_dout <= mem[bram_a_addr/BYTE_WIDTH];
            for(i=0;i<BYTE_WIDTH;i=i+1) begin
                if(bram_a_wen[i]) begin
                    mem[bram_a_addr/BYTE_WIDTH][8*i+:8] <= bram_a_din[8*i+:8];
                end
            end
        end
    end
end

always@(posedge bram_b_clk)begin
    if(bram_b_rst) begin
        bram_b_dout <= 0;
    end else begin
        if(bram_b_en) begin
            bram_b_dout <= mem[bram_b_addr/BYTE_WIDTH];
            for(i=0;i<BYTE_WIDTH;i=i+1) begin
                if(bram_b_wen[i]) begin
                    mem[bram_b_addr/BYTE_WIDTH][8*i+:8] <= bram_b_din[8*i+:8];
                end
            end
        end
    end
end
endmodule
    module XBMEM #(
    // configurable 
    parameter LOG2_MEM_DEPTH = 10,
    parameter MEM_WIDTH = 32    
) (
    (* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL,MEM_ECC NONE,READ_WRITE_MODE READ_WRITE" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_A EN" *) 	 input bram_a_en, // Chip Enable Signal (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_A DOUT" *) output [(1<<$clog2(MEM_WIDTH))-1:0] bram_a_dout, // Data Out Bus (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_A DIN" *)  input [(1<<$clog2(MEM_WIDTH))-1:0] bram_a_din, // Data In Bus (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_A WE" *) 	 input [(1<<$clog2(MEM_WIDTH/8))-1:0] bram_a_wen, // Byte Enables (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_A ADDR" *) input [LOG2_MEM_DEPTH + $clog2(MEM_WIDTH/8)-1:0] bram_a_addr, // Address Signal (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_A CLK" *)  input bram_a_clk, // Clock Signal (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_A RST" *)  input bram_a_rst, // Reset Signal (required)

    (* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL,MEM_ECC NONE,READ_WRITE_MODE READ_WRITE" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_B EN" *) 	 input bram_b_en, // Chip Enable Signal (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_B DOUT" *) output [(1<<$clog2(MEM_WIDTH))-1:0] bram_b_dout, // Data Out Bus (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_B DIN" *)  input [(1<<$clog2(MEM_WIDTH))-1:0] bram_b_din, // Data In Bus (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_B WE" *) 	 input [(1<<$clog2(MEM_WIDTH/8))-1:0] bram_b_wen, // Byte Enables (optional)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_B ADDR" *) input [LOG2_MEM_DEPTH + $clog2(MEM_WIDTH/8)-1:0] bram_b_addr, // Address Signal (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_B CLK" *)  input bram_b_clk, // Clock Signal (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_B RST" *)  input bram_b_rst // Reset Signal (required)
);

genvar i;
generate
    for(i=MEM_WIDTH;i>0;i=i-(1<<($clog2(i+1)-1))) begin : gen_bram
        bram_rtl #(
            .LOG2_MEM_DEPTH(LOG2_MEM_DEPTH),
            .MEM_WIDTH(1<<($clog2(i+1)-1))
        ) bram_inst (
            .bram_a_en(bram_a_en), // Chip Enable Signal (optional)
            .bram_a_dout(bram_a_dout[(i-1)-:1<<($clog2(i+1)-1)]), // Data Out Bus (optional)
            .bram_a_din(bram_a_din[(i-1)-:1<<($clog2(i+1)-1)]), // Data In Bus (optional)
            .bram_a_wen(bram_a_wen[(i/8-1)-:(1<<(($clog2(i+1)-1)))/8]), // Byte Enables (optional)
            .bram_a_addr(bram_a_addr>>($clog2(MEM_WIDTH) - $clog2((1<<($clog2(i+1)-1))))), // Address Signal (required)
            .bram_a_clk(bram_a_clk), // Clock Signal (required)
            .bram_a_rst(bram_a_rst), // Reset Signal (required)

            .bram_b_en(bram_b_en), // Chip Enable Signal (optional)
            .bram_b_dout(bram_b_dout[(i-1)-:1<<($clog2(i+1)-1)]), // Data Out Bus (optional)
            .bram_b_din(bram_b_din[(i-1)-:1<<($clog2(i+1)-1)]), // Data In Bus (optional)
            .bram_b_wen(bram_b_wen[(i/8-1)-:(1<<(($clog2(i+1)-1)))/8]), // Byte Enables (optional)
            .bram_b_addr(bram_b_addr>>($clog2(MEM_WIDTH) - $clog2((1<<($clog2(i+1)-1))))), // Address Signal (required)
            .bram_b_clk(bram_b_clk), // Clock Signal (required)
            .bram_b_rst(bram_b_rst) // Reset Signal (required)
        );
    end
endgenerate

endmodule
    