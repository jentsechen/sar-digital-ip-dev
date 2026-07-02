`timescale 10ps / 1ps

module BAQ_comparator_testbench;   
    //AXIL parameter
    localparam AXI_ADDR_W = 32; //byte address
    localparam AXI_DATA_W = 32;
    localparam SP_DATA_W = 32;
    parameter CLK_CYCLE=500;
    parameter ADC_WORDLENGTH = 4'd14;
    parameter MULTI_WORDLENGTH = 14;
    parameter THRESHOLD_WORDLENGTH = 14;
    parameter COMP_NUMBER_WORDLENGTH = 7;
    parameter OUTPUT_WORDLENGTH = 8;
    parameter INDEX_WORDLENGTH = 7;
    parameter BRAM_DATA_WORDLENGTH = 16;
    parameter BRAM_ADDR_WORDLENGTH = 16;
    parameter OUTPUTMOD_WORDLENGTH = 3;
    parameter THRESHOLD_NUMBER = 127;

    localparam SC_DATA_NUM = 512;
    localparam TM_DATA_NUM = 5*(127+1);

    reg EnableIn;
    reg rst;
    reg clk;
    reg [OUTPUTMOD_WORDLENGTH-1:0]NMOD;
    reg signed [MULTI_WORDLENGTH-1:0]MultiI;
    reg signed [MULTI_WORDLENGTH-1:0]MultiQ;
    reg signed [MULTI_WORDLENGTH-1:0]ComMultiI;
    reg signed [MULTI_WORDLENGTH-1:0]ComMultiQ;

    wire [15:0]bram_data[0:14];
    wire [15:0]bram_addr[0:14];
    wire [OUTPUT_WORDLENGTH-1:0]CompOutI;
    wire [OUTPUT_WORDLENGTH-1:0]CompOutQ;

    //axil IO
    reg [AXI_ADDR_W-1:0] S_AXI_AWADDR;
    reg S_AXI_AWVALID=0;
    wire S_AXI_AWREADY;
    reg [AXI_DATA_W-1:0] S_AXI_WDATA;
    reg S_AXI_WVALID=0;
    wire S_AXI_WREADY;
    wire [1:0] S_AXI_BRESP;
    wire S_AXI_BVALID;
    reg S_AXI_BREADY=1;
    reg [AXI_ADDR_W-1:0] S_AXI_ARADDR;
    reg S_AXI_ARVALID=0;
    wire S_AXI_ARREADY;
    wire [AXI_DATA_W-1:0] S_AXI_RDATA;
    wire [1:0] S_AXI_RRESP;
    wire S_AXI_RVALID;
    reg S_AXI_RREADY=0;

    compare_cell_wrap #(
        .MULTI_WORDLENGTH(MULTI_WORDLENGTH)
        ,.THRESHOLD_WORDLENGTH(THRESHOLD_WORDLENGTH)
        ,.COMP_NUMBER_WORDLENGTH(COMP_NUMBER_WORDLENGTH)
        ,.OUTPUT_WORDLENGTH(OUTPUT_WORDLENGTH)
        ,.INDEX_WORDLENGTH(INDEX_WORDLENGTH)
        ,.OUTPUTMOD_WORDLENGTH(OUTPUTMOD_WORDLENGTH)
        ,.BRAM_DATA_WORDLENGTH(BRAM_DATA_WORDLENGTH)
        ,.BRAM_ADDR_WORDLENGTH(BRAM_ADDR_WORDLENGTH)
    )
	uut (
        .clk(clk)
        ,.rst(rst)
        ,.Enable(EnableIn)
        ,.NMOD(NMOD)
        ,.MultiI(MultiI)
        ,.MultiQ(MultiQ)
        ,.ComMultiI(ComMultiI)
        ,.ComMultiQ(ComMultiQ)
        //BRAM port0
        ,.bram_data_0(bram_data[0])
        ,.bram_address_0(bram_addr[0])
        //BRAM port1
        ,.bram_data_1(bram_data[1])
        ,.bram_address_1(bram_addr[1])
        //BRAM port2
        ,.bram_data_2(bram_data[2])
        ,.bram_address_2(bram_addr[2])
        //BRAM port3
        ,.bram_data_3(bram_data[3])
        ,.bram_address_3(bram_addr[3])
        //BRAM port4
        ,.bram_data_4(bram_data[4])
        ,.bram_address_4(bram_addr[4])
        //BRAM port5
        ,.bram_data_5(bram_data[5])
        ,.bram_address_5(bram_addr[5])
        //BRAM port6
        ,.bram_data_6(bram_data[6])
        ,.bram_address_6(bram_addr[6])
        //BRAM port7
        ,.bram_data_7(bram_data[7])
        ,.bram_address_7(bram_addr[7])
        //BRAM port8
        ,.bram_data_8(bram_data[8])
        ,.bram_address_8(bram_addr[8])
        //BRAM port9
        ,.bram_data_9(bram_data[9])
        ,.bram_address_9(bram_addr[9])
        //BRAM port10
        ,.bram_data_10(bram_data[10])
        ,.bram_address_10(bram_addr[10])
        //BRAM port11
        ,.bram_data_11(bram_data[11])
        ,.bram_address_11(bram_addr[11])
        //BRAM port12
        ,.bram_data_12(bram_data[12])
        ,.bram_address_12(bram_addr[12])
        //BRAM port13
        ,.bram_data_13(bram_data[13])
        ,.bram_address_13(bram_addr[13])
        //BRAM port14
        ,.bram_data_14(bram_data[14])
        ,.bram_address_14(bram_addr[14])
        //BRAM port15
        ,.bram_data_15(bram_data[15])
        ,.bram_address_15(bram_addr[15])

        ,.CompOutI(CompOutI)
        ,.CompOutQ(CompOutQ)
    );

genvar gen_i;
integer i;
generate
    for(gen_i=0;gen_i<15;gen_i=gen_i+1)  begin:TM_block
         Threshold_Memory_set#(
             .OUTPUTMOD_WORDLENGTH(OUTPUTMOD_WORDLENGTH)
            ,.THRESHOLD_WORDLENGTH(THRESHOLD_WORDLENGTH)
            ,.THRESHOLD_NUMBER(THRESHOLD_NUMBER)
            ,.BRAM_DATA_WORDLENGTH(BRAM_DATA_WORDLENGTH)
            ,.BRAM_ADDR_WORDLENGTH(BRAM_ADDR_WORDLENGTH)
        )uut_TM(
            .clk(clk)
            ,.rst(rst)
            ,.NMOD(NMOD)
            ,.bram_data(bram_data[gen_i])
            ,.bram_addr(bram_addr[gen_i])
        );
    end
endgenerate

task axi_write;
    input [AXI_ADDR_W-1:0] ADDR;
    input [AXI_DATA_W-1:0] DATA;
    
    fork 
        begin
            @(negedge clk);
            S_AXI_AWADDR = ADDR;
            S_AXI_AWVALID = 1;
            while(S_AXI_AWREADY !== 1) @(posedge clk);
            @(negedge clk);
            S_AXI_AWVALID = 0;
        end
        begin
            S_AXI_WVALID = 1;
            S_AXI_WDATA = DATA;
            while(S_AXI_WREADY !== 1) @(posedge clk);
            @(negedge clk);
            S_AXI_WVALID = 0;
        end
    join
endtask

task axi_read;
    input [AXI_ADDR_W-1:0] ADDR;
    output [AXI_DATA_W-1:0] DATA;
    @(negedge clk);
    S_AXI_ARADDR = ADDR;
    S_AXI_ARVALID = 1;
    while(S_AXI_ARREADY !== 1) @(posedge clk);
    @(negedge clk);
    S_AXI_ARVALID = 0;
    while(S_AXI_RVALID !== 1) @(posedge clk);
    DATA = S_AXI_RDATA;
    @(negedge clk);
    S_AXI_RREADY = 1;
    @(negedge clk);
    S_AXI_RREADY = 0;
endtask
wire [9:0] tm_bram_addr_0={NMOD, bram_addr[0][6:0]};
wire [13:0] tm_bram_dout_0;
BRAM_controller u_BRAM_controller(
    .clk           (clk      ),
    .rst           (rst           ),
    .S_AXI_AWADDR  (S_AXI_AWADDR  ),
    .S_AXI_AWVALID (S_AXI_AWVALID ),
    .S_AXI_AWREADY (S_AXI_AWREADY ),
    .S_AXI_WDATA   (S_AXI_WDATA   ),
    .S_AXI_WVALID  (S_AXI_WVALID  ),
    .S_AXI_WREADY  (S_AXI_WREADY  ),
    .S_AXI_BRESP   (S_AXI_BRESP   ),
    .S_AXI_BVALID  (S_AXI_BVALID  ),
    .S_AXI_BREADY  (S_AXI_BREADY  ),
    .S_AXI_ARADDR  (S_AXI_ARADDR  ),
    .S_AXI_ARVALID (S_AXI_ARVALID ),
    .S_AXI_ARREADY (S_AXI_ARREADY ),
    .S_AXI_RDATA   (S_AXI_RDATA   ),
    .S_AXI_RRESP   (S_AXI_RRESP   ),
    .S_AXI_RVALID  (S_AXI_RVALID  ),
    .S_AXI_RREADY  (S_AXI_RREADY  ),
    .st_bram_addr  (  ),
    .st_bram_dout  (  ),
    .tm_bram_addr  (tm_bram_addr_0),
    .tm_bram_dout  (tm_bram_dout_0)
);

always #(CLK_CYCLE/2) clk = ~clk;

reg [AXI_DATA_W-1:0] data_mem [0:(SC_DATA_NUM+TM_DATA_NUM)-1];
initial $readmemb("../../../../../source_file/simulation/BRAM_controller_tb/data.mem",data_mem);   

initial begin
    // Initialize Inputs 
    rst = 0;
    clk = 1'b1; 
    NMOD=3'd4; 
    // BSMOD=2'd0;
    // SEGMOD=1'd0;
    MultiI = 0;
    MultiQ = 0;
    ComMultiI = 0;
    ComMultiQ = 0;   
    // Wait 100 ns for global reset to finish
    #(CLK_CYCLE*50) 
    rst=1'b1;
    #(CLK_CYCLE*4)
    rst=1'b0; 

    for (int i = 0;i<SC_DATA_NUM+TM_DATA_NUM ; i++) begin
            axi_write(4*i,data_mem[i]);
    end
            
    //#(CLK_CYCLE*50.5)  EnableIn=1'b0;
    //#30   EnableIn=1'b1;
    //#(CLK_CYCLE*1.95)
    //#250   
    #(CLK_CYCLE*52.5)
        EnableIn=1'b1;
        MultiI = 0;
        MultiQ = 0;
        ComMultiI = 0;
        ComMultiQ = 0;
    #(CLK_CYCLE)
        MultiI = -'d198;
        MultiQ = 'd210;
        ComMultiI = -MultiI;
        ComMultiQ = -MultiQ;
    #(CLK_CYCLE)
        MultiI = 'd1890;
        MultiQ = -'d267;
        ComMultiI = -MultiI;
        ComMultiQ = -MultiQ;
    #(CLK_CYCLE)
        MultiI = 'd739;
        MultiQ = 'd892;
        ComMultiI = -MultiI;
        ComMultiQ = -MultiQ;
    #(CLK_CYCLE)
        MultiI = 'd264;
        MultiQ = 'd642;
        ComMultiI = -MultiI;
        ComMultiQ = -MultiQ;
    #(CLK_CYCLE)
        MultiI = -'d1927;
        MultiQ = 'd48;
        ComMultiI = -MultiI;
        ComMultiQ = -MultiQ;
    #(CLK_CYCLE*50)

    $finish;

end

initial begin
  $dumpfile("BAQ_comparator_testbench.vcd");
  $dumpvars(0, BAQ_comparator_testbench);
end

 
endmodule