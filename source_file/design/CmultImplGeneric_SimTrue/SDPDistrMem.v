
    module SDPDistrMem #(parameter DEPTH = 1024, parameter WIDTH = 8)(clk,ena,enb,wea,addra,addrb,dia,dob);
        input clk,ena,enb,wea;
        input [$clog2(DEPTH)-1:0] addra,addrb;
        input [WIDTH-1:0] dia;
        output [WIDTH-1:0] dob;
        (* ram_style = "distributed" *) reg [WIDTH-1:0] ram [DEPTH-1:0];
        reg [WIDTH-1:0] doa,dob;

        always @(posedge clk) begin
            if (ena) begin
                if (wea) ram[addra] <= dia;
            end
        end
      
        always @(posedge clk) begin
            if (enb) dob <= ram[addrb];
        end
          
    endmodule
    