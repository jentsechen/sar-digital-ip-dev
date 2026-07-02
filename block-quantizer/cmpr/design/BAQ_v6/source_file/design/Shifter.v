`timescale 1ns / 1ps
module Shifter #(
//-----------parameter-----------------------------
parameter BLOCKSIZEMOD_WRODLENGTH = 2,
parameter SEGMENTATIONMOD_WORDLENGTH = 1,
parameter VARIANCEADDRESS_WORDLENGTH = 8,
parameter PARALLEL_BLOCK_SIZE_WORDLENGTH = 8,
parameter SCALING_WORDLENGTH = 15,
parameter ACC_WORDLENGTH = 29,
parameter PARALLEL_NUMBER = 4,
localparam  SHIFTOUT_CNT = $clog2(PARALLEL_NUMBER)+1+2
)(
//-----------input/output ports--------------------
input clk,
input rst,
input [SEGMENTATIONMOD_WORDLENGTH-1:0]SEGMOD,
input [BLOCKSIZEMOD_WRODLENGTH-1:0]BSMOD,
input [ACC_WORDLENGTH-1:0]ShifterIn,
input [PARALLEL_BLOCK_SIZE_WORDLENGTH-1:0]counter,
input Enable,
input fBlockEnd,

output reg[VARIANCEADDRESS_WORDLENGTH-1:0]ShifterOut,
output reg fOverFlow
);
//-----------wire/reg------------------------------
reg [SCALING_WORDLENGTH+1-1:0]CalValue; //Maximum case -> SEGMOD=1, BSMOD=0 -> needs SCALING_WORDLENGTH + 1bit 
reg temp_fOverFlow;                           
//-----------function------------------------------
always @* begin
    case(SEGMOD)                                                                          //left shift 7 bits
        1'd0: case(BSMOD)                                                                 //right shift 7 8 9 bits
                  2'd0:CalValue = {{1{1'b0}},ShifterIn[ACC_WORDLENGTH-1 -: 15]}; //15.14 -> 15.14
                  2'd1:CalValue = {{2{1'b0}},ShifterIn[ACC_WORDLENGTH-1 -: 14]}; //15.14 -> 14.15
               default:CalValue = {{3{1'b0}},ShifterIn[ACC_WORDLENGTH-1 -: 13]}; //15.14 -> 13.16
              endcase 
     default: case(BSMOD)                                                                 //left shift 8 bits & right shift 7 8 9
                  2'd0:CalValue = {ShifterIn[ACC_WORDLENGTH-1 -:16]};           //15.14 -> 16.13
                  2'd1:CalValue = {{1{1'b0}},ShifterIn[ACC_WORDLENGTH-1 -: 15]}; //15.14 -> 15.14
               default:CalValue = {{2{1'b0}},ShifterIn[ACC_WORDLENGTH-1 -: 14]}; //15.14 -> 14.15
              endcase        
    endcase
end
always @(posedge clk or posedge rst)begin
    if(rst) ShifterOut <=0;
    else begin
        if(Enable & counter == SHIFTOUT_CNT)
            case(SEGMOD)
                1'd0: 
                    if(CalValue > 127) begin
                        ShifterOut <= 8'd127;
                    end else begin
                        if(~|(CalValue[7:1]))begin
                            case(BSMOD)
                                2'd0:ShifterOut <= {1'b1, ShifterIn[14:8]};
                                2'd1:ShifterOut <= {1'b1, ShifterIn[15:9]};
                            default:ShifterOut <= {1'b1, ShifterIn[16:10]};
                            endcase 
                        end else begin
                            ShifterOut <= CalValue[VARIANCEADDRESS_WORDLENGTH-1:0];
                        end  
                    end             
             default: 
                if(CalValue > 255) ShifterOut <= 8'd255;
                else               ShifterOut <= CalValue[VARIANCEADDRESS_WORDLENGTH-1:0];
            endcase
        else ShifterOut <= ShifterOut;
    end
end
always @(posedge clk or posedge rst)begin
    if(rst) temp_fOverFlow <= 0;
    else begin
        if(Enable & counter == SHIFTOUT_CNT)
            case(SEGMOD)
                1'd0: if(CalValue > 127) temp_fOverFlow <= 1'b1;
                      else               temp_fOverFlow <= 1'b0;
             default: if(CalValue > 255) temp_fOverFlow <= 1'b1;
                      else               temp_fOverFlow <= 1'b0;
            endcase
        else temp_fOverFlow <= temp_fOverFlow;
    end
end

always @(posedge clk or posedge rst)begin
    if(rst)                    fOverFlow <=0;
    else begin
        if(Enable & fBlockEnd) fOverFlow <= temp_fOverFlow;
        
        else                   fOverFlow <= fOverFlow;
    end
end

endmodule
