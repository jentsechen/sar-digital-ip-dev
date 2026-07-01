
    module SimpleDualPortMem #(parameter DEPTH = 1024, parameter WIDTH = 8, parameter OUT_REG_EN = 1)(clk,ena,enb,wea,addra,addrb,dia,dob);
        input clk,ena,enb,wea;
        input [$clog2(DEPTH)-1:0] addra,addrb;
        input [WIDTH-1:0] dia;
        output [WIDTH-1:0] dob;
        (* ram_style = "block" *) reg [WIDTH-1:0] ram [DEPTH-1:0];
        reg [WIDTH-1:0] doa,dob;

        always @(posedge clk) begin
        if (ena) begin
            if (wea)
                ram[addra] <= dia;
            end
        end
        generate
            if(OUT_REG_EN) begin
                always @(posedge clk) begin
                    if (enb)
                    dob <= ram[addrb];
                end
            end else begin
                always@(*) dob = ram[addrb];
            end
        endgenerate
        
    endmodule
    