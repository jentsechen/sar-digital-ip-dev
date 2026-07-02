module RAMpipeFF #(
//---------------------parameter---------------------
parameter SFF_Wordlength = 1,
parameter PIPE_NUM = 1
) (
//---------------------input/output port-------------
input clk,
input rst,
input Enable,
input [SFF_Wordlength-1:0]DIN,
output [SFF_Wordlength-1:0]DOUT
);
//---------------------wire/reg----------------------
// reg [SFF_Wordlength-1:0]DIN_pipe_stage[0:PIPE_NUM];
// reg [SFF_Wordlength-1:0]pre_DIN_pipe_stage[0:PIPE_NUM];
// genvar gen_i;
// integer i;
//---------------------function----------------------
// generate
//     always @(*) begin
//         pre_DIN_pipe_stage[0] = DIN;
//         for (i=1;i<PIPE_NUM+1;i=i+1) begin
//             pre_DIN_pipe_stage[i] = DIN_pipe_stage[i-1];
//         end
//     end

//     for (gen_i=0;gen_i<PIPE_NUM+1;gen_i=gen_i+1) begin    
//         always @(posedge clk or posedge rst) begin
//             if(rst) DIN_pipe_stage[gen_i] <= 0;
//             else begin
//                 if(Enable) DIN_pipe_stage[gen_i] <= pre_DIN_pipe_stage[gen_i];
//                 else       DIN_pipe_stage[gen_i] <= DIN_pipe_stage[gen_i];
//             end
//         end      
//     end
// endgenerate
// assign DOUT = DIN_pipe_stage[PIPE_NUM-1];
generate
    if (PIPE_NUM == 1) begin : single_stage
        // 單級：直接用 FF
        reg [SFF_Wordlength-1:0] dout_reg;
        always @(posedge clk or posedge rst) begin
            if (rst)
                dout_reg <= 0;
            else if (Enable)
                dout_reg <= DIN;
        end
        assign DOUT = dout_reg;
        
    end else begin : multi_stage
        // 多級：前 N-1 級用 SRL，最後一級用 FF（支援 reset）
        (* shreg_extract = "yes", srl_style = "srl_reg" *)
        reg [SFF_Wordlength-1:0] srl_pipe [0:PIPE_NUM-2];
        
        integer i;
        always @(posedge clk) begin
            if (Enable) begin
                srl_pipe[0] <= DIN;
                for (i = 1; i < PIPE_NUM-1; i = i + 1)
                    srl_pipe[i] <= srl_pipe[i-1];
            end
        end
        
        // 最後一級 FF，支援非同步 reset
        reg [SFF_Wordlength-1:0] dout_reg;
        always @(posedge clk or posedge rst) begin
            if (rst)
                dout_reg <= 0;
            else if (Enable)
                dout_reg <= srl_pipe[PIPE_NUM-2];
        end
        assign DOUT = dout_reg;
    end
endgenerate



endmodule