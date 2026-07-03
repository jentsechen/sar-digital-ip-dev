module TestSarRxDsp;
localparam CMD_WIDTH = 2379;
localparam EXCEP_WIDTH = 27;
localparam AAF_FREQ_RESP_WIDTH = 28;
localparam IN_DATA_WIDTH = 160;
localparam OUT_DATA_WIDTH = 128;

logic           clock;
logic           reset=1'b0;
logic           aresetn=1'b1;
logic           gc_en=1'b1;
logic           core_clock=1'b0;
logic           io_inc_mode_v;
logic  [7:0]    io_inc_out_valid_start;
logic  [CMD_WIDTH-1:0] io_ind_cmd;
logic           io_ind_exception_en;
logic  [EXCEP_WIDTH-1:0]   io_ind_exception;
logic           io_ind_cmd_valid=1'b0;
logic           io_ind_aaf_en=1'b0;
logic           io_ind_aaf_wen=1'b0;
logic  [11:0]   io_ind_aaf_addr;
logic  [AAF_FREQ_RESP_WIDTH-1:0]   io_ind_aaf_data;
logic           io_ind_aaf_read_sel=1'b0;
logic           io_ind_valid=1'b0;
logic  [IN_DATA_WIDTH-1:0]  io_ind_h_data_0;
logic  [IN_DATA_WIDTH-1:0]  io_ind_h_data_1;
logic  [IN_DATA_WIDTH-1:0]  io_ind_h_data_2;
logic  [IN_DATA_WIDTH-1:0]  io_ind_h_data_3;
logic  [IN_DATA_WIDTH-1:0]  io_ind_h_data_4;
logic  [IN_DATA_WIDTH-1:0]  io_ind_h_data_5;
logic  [IN_DATA_WIDTH-1:0]  io_ind_h_data_6;
logic  [IN_DATA_WIDTH-1:0]  io_ind_h_data_7;
logic  [IN_DATA_WIDTH-1:0]  io_ind_v_data_0;
logic  [IN_DATA_WIDTH-1:0]  io_ind_v_data_1;
logic  [IN_DATA_WIDTH-1:0]  io_ind_v_data_2;
logic  [IN_DATA_WIDTH-1:0]  io_ind_v_data_3;
logic  [IN_DATA_WIDTH-1:0]  io_ind_v_data_4;
logic  [IN_DATA_WIDTH-1:0]  io_ind_v_data_5;
logic  [IN_DATA_WIDTH-1:0]  io_ind_v_data_6;
logic  [IN_DATA_WIDTH-1:0]  io_ind_v_data_7;
logic [AAF_FREQ_RESP_WIDTH-1:0]   io_out_aaf_rdata;
logic          io_out_valid;
logic          io_out_busy;
logic          io_out_last;
logic          io_out_cmd_ready;
logic [OUT_DATA_WIDTH-1:0]  io_out_h_data_0;
logic [OUT_DATA_WIDTH-1:0]  io_out_h_data_1;
logic [OUT_DATA_WIDTH-1:0]  io_out_h_data_2;
logic [OUT_DATA_WIDTH-1:0]  io_out_h_data_3;
logic [OUT_DATA_WIDTH-1:0]  io_out_v_data_0;
logic [OUT_DATA_WIDTH-1:0]  io_out_v_data_1;
logic [OUT_DATA_WIDTH-1:0]  io_out_v_data_2;
logic [OUT_DATA_WIDTH-1:0]  io_out_v_data_3;
logic [127:0]  io_out_h_rcf_out_data_0;
logic [127:0]  io_out_h_rcf_out_data_1;
logic [127:0]  io_out_h_rcf_out_data_2;
logic [127:0]  io_out_h_rcf_out_data_3;
logic [127:0]  io_out_h_rcf_out_data_4;
logic [127:0]  io_out_h_rcf_out_data_5;
logic [127:0]  io_out_h_rcf_out_data_6;
logic [127:0]  io_out_h_rcf_out_data_7;
logic          io_out_h_rcf_out_valid;
logic [127:0]  io_out_v_rcf_out_data_0;
logic [127:0]  io_out_v_rcf_out_data_1;
logic [127:0]  io_out_v_rcf_out_data_2;
logic [127:0]  io_out_v_rcf_out_data_3;
logic [127:0]  io_out_v_rcf_out_data_4;
logic [127:0]  io_out_v_rcf_out_data_5;
logic [127:0]  io_out_v_rcf_out_data_6;
logic [127:0]  io_out_v_rcf_out_data_7;
logic          io_out_v_rcf_out_valid;
logic  [23:0]   cal_in_para;
logic           cal_in_est_result_clear;
logic [15:0]   cal_out_est_result;
logic [2:0]    cal_out_state;
logic          cal_out_est_result_valid;
logic           cal_mem_in_clk;
logic           cal_mem_in_rst;
logic           cal_mem_in_en;
logic           cal_mem_in_wen;
logic  [9:0]    cal_mem_in_addr;
logic  [31:0]   cal_mem_in_din;
logic [31:0]   cal_mem_out_dout;
logic           gen_in_start;
logic [159:0]  gen_out_data;
logic          gen_out_valid;
logic [7:0]    gen_out_addr;
logic  [2:0]    vio_node_sel;
logic  [1:0]    vio_path_sel;
logic [127:0]  ila_data;
logic          ila_valid;

SarRxDsp dut(.*);

initial begin: clock_gen
    clock=1'b0;
    forever #(5.0) clock = ~clock;
end

task reset_dut();
    reset = 1'b1;
    #20;
    reset = 1'b0;
    #20;
    aresetn = 1'b0;
    #20;
    aresetn = 1'b1;
endtask
integer out_data_len;
integer out_data_len_buf [0:63];
integer in_cmd_count=0;
integer total_out_len = 0;
task read_cmd();
    integer fid_0, fid_1, fid_2;
    logic [CMD_WIDTH-1:0] cmd;
    logic [EXCEP_WIDTH-1:0] exception;
    logic exception_en;
    fid_0 = $fopen("io_ind_cmd.txt", "r");
    fid_1 = $fopen("io_ind_exception.txt", "r");
    fid_2 = $fopen("io_ind_exception_en.txt", "r");
    while(!$feof(fid_0)) begin
        if(io_out_cmd_ready) begin 
            $fscanf(fid_0, "%h\n", cmd);
            $fscanf(fid_1, "%h\n", exception);
            $fscanf(fid_2, "%h\n", exception_en);
            out_data_len = cmd[2354:2336];
            out_data_len_buf[in_cmd_count] = out_data_len;
            total_out_len = total_out_len + out_data_len;
            in_cmd_count++;
        end
        @(posedge clock);
        io_ind_cmd_valid <= 1'b1;
        io_ind_cmd <= cmd;
        io_ind_exception <= exception;
        io_ind_exception_en <= exception_en;
    end
    @(posedge clock);
    io_ind_cmd_valid <= 1'b0;
    $display("[Test bench] Set command: Done");
endtask

task read_inc();
    integer fid_0, fid_1;
    fid_0 = $fopen("io_inc_mode_v.txt", "r");
    fid_1 = $fopen("io_inc_out_valid_start.txt", "r");
    while(!$feof(fid_0)) begin
        @(posedge clock);
        $fscanf(fid_0, "%h\n", io_inc_mode_v);
        $fscanf(fid_1, "%h\n", io_inc_out_valid_start);
    end
    $display("[Test bench] Set inc: Done");
endtask

task write_aaf_freq_resp();
    integer fid, count;
    logic [AAF_FREQ_RESP_WIDTH-1:0] aaf_data;
    fid = $fopen("io_ind_aaf_data.txt", "r");
    count = 0;
    while(!$feof(fid)) begin
        $fscanf(fid, "%h\n", aaf_data);
        @(posedge clock);
        io_ind_aaf_en <=1'b1;
        io_ind_aaf_wen <=1'b1;
        io_ind_aaf_data <= aaf_data;
        io_ind_aaf_addr <= count;
        count = count + 1;
    end
    @(posedge clock);
    io_ind_aaf_en <=1'b0;
    io_ind_aaf_wen <=1'b0;
    $display("[Test bench] Write AAF freq resp: Done");
endtask

task read_aaf_freq_resp_for_check();
    integer fid, count;
    logic [AAF_FREQ_RESP_WIDTH-1:0] aaf_data;
    fid = $fopen("io_ind_aaf_data.txt", "r");
    count = 0;
    while(!$feof(fid)) begin
        $fscanf(fid, "%h\n", aaf_data);
        @(posedge clock);
        io_ind_aaf_en <=1'b1;
        io_ind_aaf_addr <= count;
        count = count + 1;
        repeat(1) @(posedge clock); //wait 1 cycle because of memory read delay
        @(negedge clock);
        if(io_out_aaf_rdata !== aaf_data) begin
            $display("[Test bench] check AAF sample no. %d: FAILED", count);
            $finish;
        end
    end
    $display("[Test bench] Readback AAF freq resp to check: PASSED");
endtask

task read_h_data();
    integer fid;
    logic [IN_DATA_WIDTH-1:0] data_0, data_1, data_2, data_3, data_4, data_5, data_6, data_7;
    fid = $fopen("io_ind_h_data.txt", "r");
    $display("[Test bench] Wait for busy down");
    while(io_out_busy) @(posedge clock);
    $display("[Test bench] Start input data");
    while(!$feof(fid)) begin
        $fscanf(fid, "%h\t", data_0);
        $fscanf(fid, "%h\t", data_1);
        $fscanf(fid, "%h\t", data_2);
        $fscanf(fid, "%h\t", data_3);
        $fscanf(fid, "%h\t", data_4);
        $fscanf(fid, "%h\t", data_5);
        $fscanf(fid, "%h\t", data_6);
        $fscanf(fid, "%h\n", data_7);
        @(posedge clock);
        io_ind_valid <= 1'b1;
        io_ind_h_data_0 <= data_0;
        io_ind_h_data_1 <= data_1;
        io_ind_h_data_2 <= data_2;
        io_ind_h_data_3 <= data_3;
        io_ind_h_data_4 <= data_4;
        io_ind_h_data_5 <= data_5;
        io_ind_h_data_6 <= data_6;
        io_ind_h_data_7 <= data_7;
    end
    @(posedge clock);
    io_ind_valid <= 1'b0;
    $display("[Test bench]Input data: Done");
endtask

integer out_data_count=0;
integer out_cmd_count=0;
task check_out_last;
    while(out_cmd_count < in_cmd_count) begin
        @(negedge clock);
        if(io_out_valid) begin
            if(out_data_count == out_data_len_buf[out_cmd_count]-1) begin
                if(io_out_last) $display("[Test bench] check command %d out last: PASSED", out_cmd_count+1);
                else $display("[Test bench] check command %d out last: NO LAST", out_cmd_count+1);
                out_data_count = 0;
                out_cmd_count++;
            end
            out_data_count++;
        end
    end
endtask

integer total_out_data_count=0;
always@(posedge clock) if(io_out_valid) total_out_data_count <= total_out_data_count + 1;

// ---- Export io_out_h_data_0 (binary) when io_out_valid ----
integer h_data_0_fid;
initial h_data_0_fid = $fopen("io_out_h_data_0_bin.txt", "w");
always@(posedge clock) if(io_out_valid) $fwrite(h_data_0_fid, "%b\n", io_out_h_data_0);

// ---- Export io_out_h_rcf_out_data_0 (binary) when io_out_h_rcf_out_valid ----
integer h_rcf_out_data_0_fid;
initial h_rcf_out_data_0_fid = $fopen("io_out_h_rcf_out_data_0_bin.txt", "w");
always@(posedge clock) if(io_out_h_rcf_out_valid) $fwrite(h_rcf_out_data_0_fid, "%b\n", io_out_h_rcf_out_data_0);

// ---- Export freq_resp_gen out AXIS datapack_data (binary) on valid && ready handshake ----
integer freq_resp_gen_fid;
initial freq_resp_gen_fid = $fopen("freq_resp_gen_out_axis_data.txt", "w");
always@(posedge clock)
    if(dut.h_dsp_core.freq_resp_gen_io_out_axis_valid && dut.h_dsp_core.freq_resp_gen_io_out_axis_ready)
        $fwrite(freq_resp_gen_fid, "%b\n", dut.h_dsp_core.freq_resp_gen_io_out_axis_datapack_data);
task check_total_output_len;
    if(total_out_data_count != total_out_len) $display("[Test bench]check total output data length: PASSED");
    else $display("[Test bench] check total output data length: FAILED");
endtask

integer check_out_data_h_count=0;
task check_out_data_h;
    integer fid;
    logic [OUT_DATA_WIDTH-1:0] data_0, data_1, data_2, data_3;
    fid = $fopen("io_out_h_data.txt", "r");
    while(check_out_data_h_count < total_out_len) begin
        @(negedge clock);
        if(io_out_valid) begin
            $fscanf(fid, "%h\t", data_0);
            $fscanf(fid, "%h\t", data_1);
            $fscanf(fid, "%h\t", data_2);
            $fscanf(fid, "%h\n", data_3);
            if(io_out_h_data_0 !== data_0) begin 
                $display("[Test bench] check H out data 0, sample %d: FAILED", check_out_data_h_count);
                $finish;
            end
            if(io_out_h_data_1 !== data_1) begin 
                $display("[Test bench] check H out data 1, sample %d: FAILED", check_out_data_h_count);
                $finish;
            end
            if(io_out_h_data_2 !== data_2) begin 
                $display("[Test bench] check H out data 2, sample %d: FAILED", check_out_data_h_count);
                $finish;
            end
            if(io_out_h_data_3 !== data_3) begin 
                $display("[Test bench] check H outdata 3, sample %d: FAILED", check_out_data_h_count);
                $finish;
            end
            check_out_data_h_count++;
        end
    end
    $display("[Test bench] check H out data %d: PASSED");
endtask

initial begin : main
    reset_dut;
    read_inc;
    write_aaf_freq_resp;
    read_aaf_freq_resp_for_check;
    read_cmd; // command be driven after write AAF freq resp
    fork    
        read_h_data;
        check_out_last;
        //check_out_data_h; // uncomment if has output file and want to check
    join
    check_total_output_len;
    #20;
    $fclose(h_data_0_fid);
    $fclose(h_rcf_out_data_0_fid);
    $fclose(freq_resp_gen_fid);
    $display("[Test bench] Finish simulation");
    $finish;
end


endmodule