module compare_cell #(
//-----------parameters---------------------------
parameter MULTI_WORDLENGTH = 14,
parameter THRESHOLD_WORDLENGTH = 14,
parameter COMP_NUMBER_WORDLENGTH = 5,
parameter OUTPUT_WORDLENGTH = 8,
parameter INDEX_WORDLENGTH = 6,
parameter BRAM_DATA_WORDLENGTH = 16,
parameter BRAM_ADDR_WORDLENGTH = 16,
parameter UPDATE_BIT = 1
) (
//-----------input/output---------------------------
    input clk,
    input rst,

    input enable_in,
    input [OUTPUT_WORDLENGTH-1:0]compress_data_in,
    input comp_in_sign,
    input [MULTI_WORDLENGTH-1:0]comp_in,
    // input [THRESHOLD_WORDLENGTH-1:0]threshold_value,
    input [INDEX_WORDLENGTH-1:0]threshold_index,      // if it is 63/95
    input [COMP_NUMBER_WORDLENGTH-1:0]comp_number_in, // if it is 64/32
    //////////////////BRAM read///////////////////////
    output [BRAM_ADDR_WORDLENGTH-1:0]bram_addr,
    // output bram_en,
    input [BRAM_DATA_WORDLENGTH-1:0]bram_data,
    //////////////////////////////////////////////////
    output comp_out_sign,
    output [MULTI_WORDLENGTH-1:0]comp_out,
    output reg[INDEX_WORDLENGTH-1:0]updated_threshold_index,
    output reg[OUTPUT_WORDLENGTH-1:0] compress_data_out,
    output [COMP_NUMBER_WORDLENGTH-1:0]comp_number_out
);
//-----------wire/reg------------------------------
genvar gen_i;
integer i;
wire [INDEX_WORDLENGTH-1:0]threshold_index_D;
wire [COMP_NUMBER_WORDLENGTH-1:0]comp_number_in_D;
wire comp_in_sign_D;
wire [MULTI_WORDLENGTH-1:0]comp_in_D;
wire [OUTPUT_WORDLENGTH-1:0]compress_data_in_D;

wire [THRESHOLD_WORDLENGTH-1:0]threshold_value;
wire [COMP_NUMBER_WORDLENGTH-1:0]comp_number_in_shift;
//-----------function-----------------------------
//BRAM config//
assign bram_addr = (enable_in)?threshold_index:threshold_index_D;

assign threshold_value = bram_data[0 +: THRESHOLD_WORDLENGTH];

////////// pipe line for align BRAM timing////////////////////////////
SingleFF #(.SFF_Wordlength(INDEX_WORDLENGTH))
	FF_threshold_index(.Enable(enable_in),.rst(rst),.DInput(threshold_index),.QOutput(threshold_index_D),.clk(clk));
SingleFF #(.SFF_Wordlength(COMP_NUMBER_WORDLENGTH))
	FF_comp_number_in(.Enable(enable_in),.rst(rst),.DInput(comp_number_in),.QOutput(comp_number_in_D),.clk(clk));
SingleFF #(.SFF_Wordlength(1))
	FF_comp_in_sign(.Enable(enable_in),.rst(rst),.DInput(comp_in_sign),.QOutput(comp_in_sign_D),.clk(clk));
SingleFF #(.SFF_Wordlength(MULTI_WORDLENGTH))
	FF_comp_in(.Enable(enable_in),.rst(rst),.DInput(comp_in),.QOutput(comp_in_D),.clk(clk));
SingleFF #(.SFF_Wordlength(MULTI_WORDLENGTH))
	FF_compress_data_in(.Enable(enable_in),.rst(rst),.DInput(compress_data_in),.QOutput(compress_data_in_D),.clk(clk));
//////////////////////////////////////////////////////////////////////
assign bypass_cond = (comp_number_in_D == comp_number_in_shift || UPDATE_BIT>7)?1:0;
assign comp_number_in_shift = comp_number_in_D >> 1;

assign comp_number_out = comp_number_in_shift;
assign comp_out_sign = comp_in_sign_D;
assign comp_out = comp_in_D;
always @(*) begin
    if (bypass_cond)begin
        compress_data_out = compress_data_in_D;
    end
    else begin
        case (comp_in_sign_D)
                  0: compress_data_out[UPDATE_BIT] = (comp_in_D<threshold_value)?0:1; 
            default: compress_data_out[UPDATE_BIT] = (comp_in_D>threshold_value)?1:0; 
        endcase
        if(UPDATE_BIT == 0)      compress_data_out[7:1] = compress_data_in_D[7:1];
        else if(UPDATE_BIT == 7) compress_data_out[6:0] = compress_data_in_D[6:0];
        else begin
                                 compress_data_out[7:UPDATE_BIT+1] = compress_data_in_D[7:UPDATE_BIT+1];
                                 compress_data_out[UPDATE_BIT-1:0] = compress_data_in_D[UPDATE_BIT-1:0];
        end
        
    end
end
always @(*) begin
    if (bypass_cond)begin
        updated_threshold_index = threshold_index_D;
    end
    else begin
        case (compress_data_out[UPDATE_BIT])
                1:begin
                    updated_threshold_index = threshold_index_D + comp_number_out; // (63+32)/(95+16)
                end 
            default:begin
                    updated_threshold_index = threshold_index_D - comp_number_out; // (63-32)/(95-16)
                end 
        endcase
    end
end


endmodule