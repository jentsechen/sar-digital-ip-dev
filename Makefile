SHELL := /bin/bash
VIVADO_INSTALL_DIR := /tools/Xilinx/Vivado/2022.2
PROJ_NAME := sar_rx_dsp_verification
PART := xczu48dr-fsvg1517-2-e

VIVADO := source $(VIVADO_INSTALL_DIR)/settings64.sh && vivado

.PHONY: default
default: gen_project

# Create the Vivado project. Rebuilds when the project-creation tcl changes.
.PHONY: gen_project
gen_project: $(PROJ_NAME)/$(PROJ_NAME).xpr

$(PROJ_NAME)/$(PROJ_NAME).xpr: source_file/tcl_command/main_project.tcl
	$(VIVADO) -mode batch -notrace -nojournal -nolog \
		-source source_file/tcl_command/main_project.tcl \
		-tclargs $(PROJ_NAME) $(PART)

# Open the generated project in the Vivado GUI.
.PHONY: gui
gui: $(PROJ_NAME)/$(PROJ_NAME).xpr
	$(VIVADO) $(PROJ_NAME)/$(PROJ_NAME).xpr &

# Run the testbench against BOTH designs and diff the exported outputs.
.PHONY: compare
compare:
	VIVADO_SETTINGS=$(VIVADO_INSTALL_DIR)/settings64.sh bash source_file/run_compare.sh

.PHONY: rm_logs
rm_logs:
	rm -rf *.log *.jou *.str

.PHONY: clean
clean: rm_logs
	rm -rf $(PROJ_NAME)/ .Xil/ sim_run/ results/ xsim.dir/
