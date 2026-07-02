SHELL := /bin/bash
VIVADO_INSTALL_DIR := /tools/Xilinx/Vivado/2022.2
PROJ_NAME := sar_rx_dsp_verification
PART := xczu48dr-fsvg1517-2-e

# Which design folder under source_file/design/ to simulate.
# Defaults to the first folder found; override on the command line, e.g.:
#   make gen_project DESIGN=CmultImplGeneric_SimTrue
DESIGN ?= $(notdir $(patsubst %/,%,$(firstword $(wildcard source_file/design/*/))))

VIVADO := source $(VIVADO_INSTALL_DIR)/settings64.sh && vivado

.PHONY: default
default: gen_project

# Create the Vivado project for the selected DESIGN (regenerates each time).
.PHONY: gen_project
gen_project:
	$(VIVADO) -mode batch -notrace -nojournal -nolog \
		-source source_file/tcl_command/main_project.tcl \
		-tclargs $(PROJ_NAME) $(PART) $(DESIGN)

# Generate the project for DESIGN and run its behavioral simulation (batch).
#   make sim DESIGN=CmultImplGeneric_SimTrue
.PHONY: sim
sim: gen_project
	$(VIVADO) -mode batch -notrace -nojournal -nolog \
		$(PROJ_NAME)/$(PROJ_NAME).xpr \
		-source source_file/tcl_command/run_sim.tcl

# Open the generated project in the Vivado GUI.
.PHONY: gui
gui:
	$(VIVADO) $(PROJ_NAME)/$(PROJ_NAME).xpr &

.PHONY: rm_logs
rm_logs:
	rm -rf *.log *.jou *.str

.PHONY: clean
clean: rm_logs
	rm -rf $(PROJ_NAME)/ .Xil/ xsim.dir/
