module BRAM_controller #(
    parameter SHIFT_WORDLENGTH = 8,
    parameter SCALING_NUMBER = 256,
    parameter SCALING_WORDLENGTH = 17,
    
    parameter OUTPUTMOD_WORDLENGTH = 3,
    parameter THRESHOLD_NUMBER_W = 7,
    parameter THRESHOLD_WORDLENGTH = 14,
    parameter TM_BRAM_NUM = 32,
    localparam TM_DATA_CH = TM_BRAM_NUM*2,
    
    parameter ST_DATA_NUM = 512,
    parameter TM_DATA_NUM = 5*(127+1),
    
    localparam BRAM_DEPTH = ST_DATA_NUM+TM_DATA_NUM,

    //AXIL TO SP parameter
    localparam SP_ADDR_W = $clog2(BRAM_DEPTH),
    localparam SP_DATA_W = 32

) (
    input clk,
    input rst,

    input Enable,


    /********AXIL TO SP IO*******/
    input sp_en,
    input sp_wen,
    input [SP_ADDR_W-1:0] sp_addr,  // 32-bits word address, instead of byte address
    input [SP_DATA_W-1:0] sp_wdata,
    output [SP_DATA_W-1:0] sp_rdata,


    /********scaling table interface*******/
    input    [(SHIFT_WORDLENGTH+1)-1:0] st_bram_addr,//{SEGMOD,Address}
    output reg [SCALING_WORDLENGTH-1:0] st_bram_dout,//DataOut

    /********threshold memory interface*******/
    input [TM_DATA_CH*(OUTPUTMOD_WORDLENGTH+THRESHOLD_NUMBER_W)-1:0]tm_bram_addr,//{NMODE,Address}
    output reg [TM_DATA_CH*THRESHOLD_WORDLENGTH-1:0]tm_bram_dout
);



localparam LOG2_ST_MEM_DEPTH = $clog2(ST_DATA_NUM); //512
localparam LOG2_TM_MEM_DEPTH = $clog2(TM_DATA_NUM); //1024
localparam MEM_WIDTH = 16;

//FSM state
localparam LOAD_INIT = 1'd0;
localparam IP_ACTIVE = 1'd1;

reg [3:0]state_reg, state_next;

reg init_load_done;
//control registers instantiation
always@(posedge clk) begin // write field
    if(rst) begin
        init_load_done <= 0;
    end else if(sp_en && sp_wen) begin // CR address space
        case(sp_addr) // 32-bits word address, instead of byte address
            ST_DATA_NUM + TM_DATA_NUM: init_load_done <= sp_wdata[0];
        endcase
    end else begin
        init_load_done <= 0;
    end
end

reg [SP_DATA_W-1:0] sp_rdata_cr,sp_rdata_bram ;
always@(posedge clk) begin // read field
    if(rst) begin
        sp_rdata_cr <= 0;
    end else if(sp_en) begin // CR address space
        case(sp_addr) // 32-bits word address, instead of byte address
            ST_DATA_NUM + TM_DATA_NUM: sp_rdata_cr <= init_load_done;
        endcase
    end
end


reg [SP_ADDR_W-1:0] sp_addr_reg;


assign sp_rdata = (sp_addr_reg<ST_DATA_NUM + TM_DATA_NUM)?sp_rdata_bram:sp_rdata_cr;

reg st_bram_a_en;
reg [1:0]st_bram_a_wen;
reg [LOG2_ST_MEM_DEPTH + $clog2(MEM_WIDTH/8)-1:0] st_bram_a_addr;
reg [(1<<$clog2(MEM_WIDTH))-1:0] st_bram_a_din;
wire [(1<<$clog2(MEM_WIDTH))-1:0] st_bram_a_dout;
reg [TM_BRAM_NUM-1:0]tm_bram_a_en;
reg [(TM_BRAM_NUM*2)-1:0]tm_bram_a_wen;
reg [(TM_BRAM_NUM*(LOG2_TM_MEM_DEPTH + $clog2(MEM_WIDTH/8)))-1:0] tm_bram_a_addr;
reg [(TM_BRAM_NUM*(1<<$clog2(MEM_WIDTH)))-1:0] tm_bram_a_din;
wire [(TM_BRAM_NUM*(1<<$clog2(MEM_WIDTH)))-1:0] tm_bram_a_dout;
reg [TM_BRAM_NUM-1:0]tm_bram_b_en;
reg [(TM_BRAM_NUM*2)-1:0]tm_bram_b_wen;
reg [(TM_BRAM_NUM*(LOG2_TM_MEM_DEPTH + $clog2(MEM_WIDTH/8)))-1:0] tm_bram_b_addr;
reg [(TM_BRAM_NUM*(1<<$clog2(MEM_WIDTH)))-1:0] tm_bram_b_din;
wire [(TM_BRAM_NUM*(1<<$clog2(MEM_WIDTH)))-1:0] tm_bram_b_dout;
wire [(LOG2_TM_MEM_DEPTH + $clog2(MEM_WIDTH/8))-1:0] sp_tm_addr = sp_addr-ST_DATA_NUM;
//output logic
integer i;
always @( *) begin
    st_bram_a_en = 0;
    st_bram_a_wen = 0;
    st_bram_a_addr = 0;
    st_bram_a_din = 0;
    tm_bram_a_en = 0;
    tm_bram_a_wen = 0;
    tm_bram_a_addr = 0;
    tm_bram_a_din = 0;
    tm_bram_b_en = 0;
    tm_bram_b_wen = 0;
    tm_bram_b_addr = 0;
    tm_bram_b_din = 0;
    sp_rdata_bram = 0;
    st_bram_dout = 0;
    tm_bram_dout = 0;
    case(state_reg) 

        LOAD_INIT: begin
            if (sp_en && sp_wen) begin // write field
                if (sp_addr < ST_DATA_NUM) begin
                    st_bram_a_en = sp_en;
                    st_bram_a_wen = {2{sp_wen}};
                    st_bram_a_addr = sp_addr << 1;
                    st_bram_a_din = sp_wdata;
                end else if(sp_addr < ST_DATA_NUM + TM_DATA_NUM)begin
                    tm_bram_a_en = {TM_BRAM_NUM{sp_en}};
                    tm_bram_a_wen = {TM_BRAM_NUM{{sp_wen, sp_wen}}};
                    tm_bram_a_addr = {TM_BRAM_NUM{sp_tm_addr << 1}};
                    for (i = 0 ; i < TM_BRAM_NUM ; i = i + 1 ) begin
                        tm_bram_a_din[i*(1<<$clog2(MEM_WIDTH))+:(1<<$clog2(MEM_WIDTH))] = sp_wdata;
                    end
                end
            end else if (sp_en) begin // read field-1
                st_bram_a_en = 1;
                st_bram_a_wen = 2'b0;
                st_bram_a_addr = sp_addr << 1;
                tm_bram_a_en[0] = 1;
                tm_bram_a_wen[1:0] = 2'b0;
                tm_bram_a_addr[0+:(LOG2_TM_MEM_DEPTH + $clog2(MEM_WIDTH/8))] = (sp_addr-ST_DATA_NUM) << 1;
            end

            if (sp_addr_reg < ST_DATA_NUM) begin // read field-2
                sp_rdata_bram = st_bram_a_dout;
            end else if(sp_addr_reg < ST_DATA_NUM + TM_DATA_NUM)begin
                sp_rdata_bram = tm_bram_a_dout[0+:(1<<$clog2(MEM_WIDTH))];
            end
        end

        IP_ACTIVE: begin
            st_bram_a_en = Enable;
            st_bram_a_wen = 0;
            st_bram_a_addr = st_bram_addr << 1;
            st_bram_dout = st_bram_a_dout;
            tm_bram_a_en = {TM_BRAM_NUM{1'b1}};
            tm_bram_a_wen = 0;
            for (i = 0 ; i < TM_BRAM_NUM ; i = i + 1 ) begin
                tm_bram_a_addr[(i*(LOG2_TM_MEM_DEPTH + $clog2(MEM_WIDTH/8)))+:(LOG2_TM_MEM_DEPTH + $clog2(MEM_WIDTH/8))] = 
                tm_bram_addr[((i*2)*(OUTPUTMOD_WORDLENGTH+THRESHOLD_NUMBER_W))+:(OUTPUTMOD_WORDLENGTH+THRESHOLD_NUMBER_W)] << 1;
                tm_bram_dout[(i*2)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH] = 
                tm_bram_a_dout[i*(1<<$clog2(MEM_WIDTH))+:(1<<$clog2(MEM_WIDTH))];
            end
            tm_bram_b_en = {TM_BRAM_NUM{1'b1}};
            tm_bram_b_wen = 0;
            for (i = 0 ; i < TM_BRAM_NUM ; i = i + 1 ) begin
                tm_bram_b_addr[(i*(LOG2_TM_MEM_DEPTH + $clog2(MEM_WIDTH/8)))+:(LOG2_TM_MEM_DEPTH + $clog2(MEM_WIDTH/8))] = 
                tm_bram_addr[((i*2+1)*(OUTPUTMOD_WORDLENGTH+THRESHOLD_NUMBER_W))+:(OUTPUTMOD_WORDLENGTH+THRESHOLD_NUMBER_W)] << 1;
                tm_bram_dout[(i*2+1)*THRESHOLD_WORDLENGTH+:THRESHOLD_WORDLENGTH] = 
                tm_bram_b_dout[i*(1<<$clog2(MEM_WIDTH))+:(1<<$clog2(MEM_WIDTH))];
            end

            sp_rdata_bram = 32'h80000000;
        end
    endcase
end


always @(*) begin
    state_next = LOAD_INIT;
    case(state_reg) 
        LOAD_INIT: begin
            state_next = LOAD_INIT;
            if(init_load_done) state_next = IP_ACTIVE;
        end
        IP_ACTIVE: begin
            state_next = IP_ACTIVE;
        end
    endcase
end


always @(posedge clk ) begin
    if (rst) begin
        state_reg <= 0;
        sp_addr_reg <= 0;
    end else begin
        state_reg <= state_next;
        sp_addr_reg <= sp_addr;
    end
end


//scaling table bram inst
bus_align_bram_rtl #(
    .LOG2_MEM_DEPTH(LOG2_ST_MEM_DEPTH),
    .MEM_WIDTH(MEM_WIDTH)
)    
u_st_bram(
    .bram_a_clk  (clk),
    .bram_a_rst  (rst),
    .bram_a_en   (st_bram_a_en),
    .bram_a_wen  (st_bram_a_wen),
    .bram_a_addr (st_bram_a_addr),
    .bram_a_din  (st_bram_a_din),
    .bram_a_dout (st_bram_a_dout)
);


//threshold memory bram inst
genvar gen_i;
generate
    for (gen_i = 0 ; gen_i < TM_BRAM_NUM ; gen_i=gen_i+1 ) begin : u_tm_bram
        bus_align_bram_rtl #(
            .LOG2_MEM_DEPTH(LOG2_TM_MEM_DEPTH),
            .MEM_WIDTH(MEM_WIDTH)
        )
        u_tm_bram_rtl(
            .bram_a_clk  (clk),
            .bram_a_rst  (rst),
        	.bram_a_en   (tm_bram_a_en[gen_i]),
            .bram_a_wen  (tm_bram_a_wen[gen_i*2+:2]),
            .bram_a_addr (tm_bram_a_addr[(gen_i*(LOG2_TM_MEM_DEPTH + $clog2(MEM_WIDTH/8)))+:(LOG2_TM_MEM_DEPTH + $clog2(MEM_WIDTH/8))]),
            .bram_a_din  (tm_bram_a_din[gen_i*(1<<$clog2(MEM_WIDTH))+:(1<<$clog2(MEM_WIDTH))]),
            .bram_a_dout (tm_bram_a_dout[gen_i*(1<<$clog2(MEM_WIDTH))+:(1<<$clog2(MEM_WIDTH))]),
            
            .bram_b_clk  (clk),
            .bram_b_rst  (rst),
            .bram_b_en   (tm_bram_b_en[gen_i]),
            .bram_b_wen  (tm_bram_b_wen[gen_i*2+:2]),
            .bram_b_addr (tm_bram_b_addr[(gen_i*(LOG2_TM_MEM_DEPTH + $clog2(MEM_WIDTH/8)))+:(LOG2_TM_MEM_DEPTH + $clog2(MEM_WIDTH/8))]),
            .bram_b_din  (tm_bram_b_din[gen_i*(1<<$clog2(MEM_WIDTH))+:(1<<$clog2(MEM_WIDTH))]),
            .bram_b_dout (tm_bram_b_dout[gen_i*(1<<$clog2(MEM_WIDTH))+:(1<<$clog2(MEM_WIDTH))])
        );
        
    end
endgenerate

    
endmodule