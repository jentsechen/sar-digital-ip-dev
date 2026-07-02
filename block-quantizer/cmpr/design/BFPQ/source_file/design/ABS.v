`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:39:05 08/30/2018 
// Design Name: 
// Module Name:    ABS 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ABS(inI, inQ, outI, outQ, signI, signQ
    );
input signed[13:0] inI, inQ;
output reg [12:0] outI, outQ;
output reg signI, signQ;

always @(*) begin
  if (inI[13] == 1'b1) begin
    outI = -inI;
	 signI=1;
  end
  else begin
    outI = inI;
	 signI=0;
  end
end

always @(*) begin
  if (inQ[13] == 1'b1) begin
    outQ = -inQ;
	 signQ=1;
  end
  else begin
    outQ = inQ;
	 signQ=0;
  end
end

endmodule
