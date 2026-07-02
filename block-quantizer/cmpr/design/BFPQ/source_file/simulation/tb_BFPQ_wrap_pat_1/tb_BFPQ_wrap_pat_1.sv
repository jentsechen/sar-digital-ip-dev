`timescale 1ns / 1ps
`define CYCLE 10

module tb_BFPQ_wrap_pat_1;
//configurable
localparam RANDOM_VALID = 0;
localparam RANDOM_READY = 0;
localparam BMOD = 2;
localparam MMOD = 4;
localparam BLOCK_NUM = 200;
localparam PRI = 1;

parameter NUMBLOCK_W = 16;
parameter NUM_DATA_PATH = 4;
parameter IQ = 2;
parameter DSP_DATA_BITS = 16;
parameter ADC_WORDLENGTH = 14;
parameter BLOCKSIZEMOD_WRODLENGTH = 2; 
parameter OUTPUT_WORDLENGTH = 14;
parameter OUTPUTMOD_WORDLENGTH = 3;
parameter PARALLEL_NUMBER = 4;
parameter BFPQ_HEAD_W = 9;

logic rst = 0;
logic clk = 1;
logic [BLOCKSIZEMOD_WRODLENGTH-1:0]block_size_mode;   
logic [OUTPUTMOD_WORDLENGTH-1:0]word_length_mode;  
logic [NUMBLOCK_W-1:0]NumBlock;
logic S_AXIS_IN_TVALID = 0;  
logic S_AXIS_IN_TREADY;  
logic [NUM_DATA_PATH*IQ*DSP_DATA_BITS-1:0]S_AXIS_IN_TDATA = 0;   
logic S_AXIS_IN_TLAST = 0;   
logic M_AXIS_OUT_TVALID; 
logic M_AXIS_OUT_TREADY=0; 
logic [BFPQ_HEAD_W+PARALLEL_NUMBER*2*OUTPUT_WORDLENGTH-1:0]M_AXIS_OUT_TDATA;  
logic M_AXIS_OUT_TLAST;  

BFPQ_wrap u_BFPQ_wrap(
    .clk               (clk               ),
    .rst               (rst               ),
    .block_size_mode   (block_size_mode   ),
    .word_length_mode  (word_length_mode  ),
    .S_AXIS_IN_TVALID  (S_AXIS_IN_TVALID  ),
    .S_AXIS_IN_TREADY  (S_AXIS_IN_TREADY  ),
    .S_AXIS_IN_TDATA   (S_AXIS_IN_TDATA   ),
    .S_AXIS_IN_TLAST   (S_AXIS_IN_TLAST   ),
    .M_AXIS_OUT_TVALID (M_AXIS_OUT_TVALID ),
    .M_AXIS_OUT_TREADY (M_AXIS_OUT_TREADY ),
    .M_AXIS_OUT_TDATA  (M_AXIS_OUT_TDATA  ),
    .M_AXIS_OUT_TLAST  (M_AXIS_OUT_TLAST  )
);


logic [16-1:0] test_pat [100000];//num_block*block_size*iq
initial $readmemb("../../../../../source_file/simulation/tb_BFPQ_wrap_pat_1/test_pat_1.mem",test_pat);
// initial $readmemb("./test_pat.mem",test_pat);


//dump to waveform
initial begin
    $dumpfile("tb_BFPQ_wrap.vcd");
    $dumpvars(0);
end

always begin
    #(`CYCLE/2) clk = ~clk;
end

int seed = 2; 

int in_sample;
assign in_sample = NumBlock * u_BFPQ_wrap.block_size_sample;

initial begin
    // Initialize Inputs
    block_size_mode=BMOD;
    word_length_mode=MMOD;
    NumBlock = BLOCK_NUM;
    
    // //global reset
    #(`CYCLE*50) 
    rst=1'b1;
    #(`CYCLE*4)
    rst=1'b0; 
    //main data handshake input
    #(`CYCLE*52.5)
    S_AXIS_IN_TVALID = 1'b1;
    @(negedge clk);
    repeat(PRI)begin
        for (int i = 0; i < in_sample; i++) begin //(num_block*block_size)/parallel_num
        S_AXIS_IN_TDATA = {test_pat[i*8+7]<<2,
                           test_pat[i*8+6]<<2,
                           test_pat[i*8+5]<<2,
                           test_pat[i*8+4]<<2,
                           test_pat[i*8+3]<<2,
                           test_pat[i*8+2]<<2,
                           test_pat[i*8+1]<<2,
                           test_pat[i*8+0]<<2};//{Q4,I4,Q3,I3,Q2,I2,Q1,I1}   
        S_AXIS_IN_TLAST = (i == in_sample-1);
        if(RANDOM_VALID) S_AXIS_IN_TVALID=$random(seed);  
        else S_AXIS_IN_TVALID=1;
        while(~S_AXIS_IN_TVALID)begin
            @(negedge clk);
            S_AXIS_IN_TVALID=$random(seed);
        end
        while(~S_AXIS_IN_TREADY)@(posedge clk);
        @(negedge clk);
        end
        S_AXIS_IN_TVALID=0;
    end


    

    #(1024*`CYCLE) 

    $finish;
end


always_ff @( posedge clk ) begin : rand_rdy
    if(RANDOM_READY) begin
        M_AXIS_OUT_TREADY <= $random(seed);    
    end else begin
        M_AXIS_OUT_TREADY <= 1;
    end
end


logic [4-1:0]wordlength;
always @(*) begin
    case(word_length_mode)
        3'd0: wordlength = 'd2;
        3'd1: wordlength = 'd3;
        3'd2: wordlength = 'd4;
        3'd3: wordlength = 'd6;
        3'd4: wordlength = 'd8;
        default: wordlength = 'd0;
    endcase
end


integer i; 
integer Result_I, Result_Q;
integer Result_I1, Result_Q1;
integer Result_I2, Result_Q2;
integer Result_I3, Result_Q3;
integer Result_I4, Result_Q4;
integer Result_header;  

initial begin
    $system($sformatf("rm -rf ../../../../../source_file/simulation/tb_BFPQ_wrap_pat_1/output/"));
    $system($sformatf("mkdir ../../../../../source_file/simulation/tb_BFPQ_wrap_pat_1/output/"));
    Result_I = $fopen("../../../../../source_file/simulation/tb_BFPQ_wrap_pat_1/output/BFPQ_output_I.txt");
    Result_Q = $fopen("../../../../../source_file/simulation/tb_BFPQ_wrap_pat_1/output/BFPQ_output_Q.txt");
    Result_header = $fopen("../../../../../source_file/simulation/tb_BFPQ_wrap_pat_1/output/BFPQ_output_header.txt");
                
    for(i=0; i <10000000; i= i +1) begin 
        if(M_AXIS_OUT_TREADY && M_AXIS_OUT_TVALID)  begin  
            $fdisplay(Result_I,"%0d ", M_AXIS_OUT_TDATA[7*14+:7]);
            $fdisplay(Result_Q,"%0d ", M_AXIS_OUT_TDATA[6*14+:7]);
            $fdisplay(Result_I,"%0d ", M_AXIS_OUT_TDATA[5*14+:7]);
            $fdisplay(Result_Q,"%0d ", M_AXIS_OUT_TDATA[4*14+:7]);
            $fdisplay(Result_I,"%0d ", M_AXIS_OUT_TDATA[3*14+:7]);
            $fdisplay(Result_Q,"%0d ", M_AXIS_OUT_TDATA[2*14+:7]);
            $fdisplay(Result_I,"%0d ", M_AXIS_OUT_TDATA[1*14+:7]);
            $fdisplay(Result_Q,"%0d ", M_AXIS_OUT_TDATA[0*14+:7]);
            if(u_BFPQ_wrap.fBlockEnd==1'b1) begin
                $fdisplay(Result_header,"%d ", M_AXIS_OUT_TDATA[PARALLEL_NUMBER*2*OUTPUT_WORDLENGTH+:BFPQ_HEAD_W]);
            end
        end
        #(`CYCLE);
    end
    $fclose(Result_I1);
    $fclose(Result_I2);
    $fclose(Result_I3);
    $fclose(Result_I4);
    $fclose(Result_Q1);
    $fclose(Result_Q2);
    $fclose(Result_Q3);
    $fclose(Result_Q4);

    $fclose(Result_header);
end

endmodule

