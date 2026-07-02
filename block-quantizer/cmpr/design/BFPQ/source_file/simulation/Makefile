
BFPQ_DIR := ../../../bfpq_ip

TESTBENCH = tb_BFPQ_wrap

SOURCES_V := \
	$(BFPQ_DIR)/source_file/design/BFPQ_wrap.v \
	$(BFPQ_DIR)/source_file/design/ABS.v  \
	$(BFPQ_DIR)/source_file/design/bfpq_SingleFF.v \
	$(BFPQ_DIR)/source_file/design/DFF.v \
	$(BFPQ_DIR)/source_file/design/InputBuffering_v2.v \
	$(BFPQ_DIR)/source_file/design/Max_v3.v \
	$(BFPQ_DIR)/source_file/design/Scaling_v2.v\
	$(BFPQ_DIR)/source_file/design/bfpq_Multiplier.v \
	$(BFPQ_DIR)/source_file/design/BFPQ_tunable_4way_v2.v \
	$(BFPQ_DIR)/source_file/design/ExpTable.v \
	$(BFPQ_DIR)/source_file/design/InverseAlphaTable.v \
	$(BFPQ_DIR)/source_file/design/MultiplierTune.v \
	$(BFPQ_DIR)/source_file/design/SRAM.v \
	$(BFPQ_DIR)/source_file/design/bfpq_NESingleFF.v \
	$(BFPQ_DIR)/source_file/design/Exp.v \
	$(BFPQ_DIR)/source_file/design/InverseWTable.v \
	$(BFPQ_DIR)/source_file/design/Quantizer_v4.v \
	$(BFPQ_DIR)/source_file/design/WTable.v \

SOURCES_SV := \
    ./${TESTBENCH}.sv \

all: clean simulate

simulate:
	iverilog -o $(TESTBENCH).vvp -I ./../../../comp_sf_integration/source_file/include/ -g2005-sv $(SOURCES_V) $(SOURCES_SV)
	vvp $(TESTBENCH).vvp

wave:
	gtkwave $(TESTBENCH).vcd&

clean:
	rm -rf $(TESTBENCH).vvp $(TESTBENCH).vcd 
	rm -rf output_files/*.bin