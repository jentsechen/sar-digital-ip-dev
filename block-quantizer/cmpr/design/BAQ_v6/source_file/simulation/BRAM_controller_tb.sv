`timescale 1ns / 1ps
`define CYCLE 10
module BRAM_controller_tb() ;

//AXIL parameter
localparam AXI_ADDR_W = 32; //byte address
localparam AXI_DATA_W = 32;
localparam SP_DATA_W = 32;

parameter SHIFT_WORDLENGTH = 8;
parameter SCALING_NUMBER = 256;
parameter SCALING_WORDLENGTH = 15;

parameter OUTPUTMOD_WORDLENGTH = 3;
parameter THRESHOLD_NUMBER_W = 7;
parameter THRESHOLD_WORDLENGTH = 14;
parameter TM_BRAM_NUM = 32;
parameter TM_DATA_CH = TM_BRAM_NUM*2;

localparam ST_DATA_NUM = 512;
localparam TM_DATA_NUM = 5*(127+1);
localparam BRAM_DEPTH = ST_DATA_NUM+TM_DATA_NUM;
localparam SP_ADDR_W = $clog2(BRAM_DEPTH);


reg clk=0, rst=1;

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

logic baq_sp_en;
logic baq_sp_wen;
logic [SP_ADDR_W-1:0] baq_sp_addr;
logic [SP_DATA_W-1:0] baq_sp_wdata;
logic [SP_DATA_W-1:0] baq_sp_rdata;

reg [AXI_DATA_W-1:0] axil_read_data;

reg [(SHIFT_WORDLENGTH+1)-1:0] st_bram_addr;//{SEGMOD,Address}
reg [SCALING_WORDLENGTH-1:0] st_bram_dout;//DataOut
reg [TM_DATA_CH*(OUTPUTMOD_WORDLENGTH+THRESHOLD_NUMBER_W)-1:0]tm_bram_addr;//{NMODE,Address}
reg [TM_DATA_CH*THRESHOLD_WORDLENGTH-1:0]tm_bram_dout;

reg [AXI_DATA_W-1:0] bram_init_data [0:(ST_DATA_NUM+TM_DATA_NUM)-1];

reg st_read_done, tm_read_done;
reg [(OUTPUTMOD_WORDLENGTH+THRESHOLD_NUMBER_W)-1:0]tm_addr_mem[0:TM_DATA_CH-1];

initial $readmemb("../../../../../source_file/simulation/bram_init_data.mem",bram_init_data);


always #(`CYCLE/2) clk = ~clk;

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

BRAM_controller u_BRAM_controller(
    .clk           (clk           ),
    .rst           (rst           ),
    .Enable        (1             ),
    .sp_en         (baq_sp_en     ),
    .sp_wen        (baq_sp_wen    ),
    .sp_addr       (baq_sp_addr   ),
    .sp_wdata      (baq_sp_wdata  ),
    .sp_rdata      (baq_sp_rdata  ),
    .st_bram_addr  (st_bram_addr  ),
    .st_bram_dout  (st_bram_dout  ),
    .tm_bram_addr  (tm_bram_addr  ),
    .tm_bram_dout  (tm_bram_dout  )
);

axi_lite_to_sp #(
    .SP_ADDR_W(SP_ADDR_W)
)u_axi_lite_to_sp(
    .clk           (clk           ),
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

    .sp_en         (baq_sp_en         ),
    .sp_wen        (baq_sp_wen        ),
    .sp_addr       (baq_sp_addr       ),
    .sp_wdata      (baq_sp_wdata      ),
    .sp_rdata      (baq_sp_rdata      )
    
);

int read_data;
integer k;
initial begin
    st_read_done = 0;
    for (int i = 0;i< TM_DATA_CH; i++) begin
        tm_addr_mem[i] = 638-i;
    end
    // tm_addr_mem[0]= 0;
    // tm_addr_mem[1]= 129;
    // tm_addr_mem[2]= 258;
    // tm_addr_mem[3]= 385;
    // tm_addr_mem[4]= 394;
    // tm_addr_mem[5]= 410;
    // tm_addr_mem[6]= 512;
    // tm_addr_mem[7]= 534;
    // tm_addr_mem[8]= 555;
    // tm_addr_mem[9]= 590;
    // tm_addr_mem[10]= 618;
    // tm_addr_mem[11]= 626;
    // tm_addr_mem[12]= 632;
    // tm_addr_mem[13]= 638;
    // tm_addr_mem[14]= 258;
    // tm_addr_mem[15]= 128;
    tm_read_done = 0;
    #(`CYCLE*20)
    rst = 0;

    for (int i = 0;i<ST_DATA_NUM+TM_DATA_NUM ; i++) begin
        axi_write(4*i,bram_init_data[i]);
    end
    for (int i = 0;i<ST_DATA_NUM+TM_DATA_NUM ; i++) begin
        axi_read(4*i,read_data);
        $display("AXIL Read addr: %0d , data: %0h",i,read_data);
    end
    axi_write(4*(ST_DATA_NUM+TM_DATA_NUM),1);

    @(posedge clk);
    for (int i = 0 ; i<512 ; i++) begin
        st_bram_addr = i;
        for (int j = 0;j<TM_DATA_CH ;j++ ) begin
            tm_bram_addr[j*(OUTPUTMOD_WORDLENGTH+THRESHOLD_NUMBER_W)+:(OUTPUTMOD_WORDLENGTH+THRESHOLD_NUMBER_W)] = i;
        end
        @(posedge clk);
    end
    #(`CYCLE*10)
    // axi_read(4*64, axil_read_data);

    fork
        begin
            st_bram_addr = 380;
            #(`CYCLE)
            @(negedge clk);
            st_read_done = 1;
            #(`CYCLE)
            st_read_done = 0;
        end
        begin
            for (int i = 0;i< TM_DATA_CH; i++) begin
                tm_bram_addr[i*(OUTPUTMOD_WORDLENGTH+THRESHOLD_NUMBER_W)+:(OUTPUTMOD_WORDLENGTH+THRESHOLD_NUMBER_W)] = tm_addr_mem[i];
            end
            #(`CYCLE)
            @(negedge clk);
            tm_read_done = 1;
            #(`CYCLE)
            tm_read_done = 0; 
        end
    join
    
    
    repeat(1000) @(negedge clk);
    $finish();
end


// initial begin
//     $monitor("BRAM read result: %h", axil_read_data);  
// end

always @(*) begin
    if (st_read_done) begin
        $display("ST BRAM result addr %0d: 0x%h",st_bram_addr, st_bram_dout);  
    end
    if (tm_read_done) begin
        for (k = 0;k< TM_DATA_CH; k++) begin
            $display("TM BRAM result ch %0d, addr %0d: 0x%h", k, tm_addr_mem[k], tm_bram_dout[k*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH]);  
        end
    end
end
    
endmodule