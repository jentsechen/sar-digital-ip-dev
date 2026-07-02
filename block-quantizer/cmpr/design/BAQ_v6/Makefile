SHELL := /bin/bash
VIVADO_INSTALL_DIR := /tools/Xilinx/Vivado/2022.2
PROJ_NAME := BAQ_v6_prj

REPO_SERVER_HOST := 10.100.70.180
SSH_OPTS := -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no



check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))


.PHONY: default
default: gen_project run_implementation create_hardware

.PHONY: gen_project
gen_project: $(PROJ_NAME)/$(PROJ_NAME).xpr

# gen_project should rebuild whenever source_file/*.tcl changes 
$(PROJ_NAME)/$(PROJ_NAME).xpr:
	source $(VIVADO_INSTALL_DIR)/settings64.sh && vivado -mode batch -source source_file/tcl_command/main_project.tcl -notrace

.PHONY: gui
gui: $(PROJ_NAME)/$(PROJ_NAME).xpr
	source $(VIVADO_INSTALL_DIR)/settings64.sh && vivado $(PROJ_NAME)/$(PROJ_NAME).xpr &

.PHONY: create_hardware
create_hardware: 
	source $(VIVADO_INSTALL_DIR)/settings64.sh && vivado -mode batch -notrace $(PROJ_NAME)/$(PROJ_NAME).xpr	-nojournal -nolog -source source_file/tcl_command/create_hardware.tcl

.PHONY: update_bd_tcl
update_bd_tcl:
	source $(VIVADO_INSTALL_DIR)/settings64.sh && vivado -mode batch -notrace $(PROJ_NAME)/$(PROJ_NAME).xpr	-nojournal -nolog -source source_file/tcl_command/update_bd_tcl.tcl

.PHONY: rm_logs
rm_logs:
	rm -rf *.log *.jou *.str

.PHONY: clean
clean: rm_logs
	rm -rf $(PROJ_NAME)/ .Xil/
	rm -f ./source_file/simulation/tb_BAQ_4way/output/*
	rm -f ./source_file/simulation/tb_BAQ_wrap/output/*

.PHONY: upload_hardware_export
upload_hardware_export:
	scp $(SSH_OPTS) source_file/hardware_export/* ra2@$(REPO_SERVER_HOST):/var/repo-web/fpga_export/template

.PHONY: run_implementation
run_implementation: 
	source $(VIVADO_INSTALL_DIR)/settings64.sh && vivado -mode batch -notrace $(PROJ_NAME)/$(PROJ_NAME).xpr	-nojournal -nolog -source source_file/tcl_command/run_implementation.tcl

.PHONY: py_compare_baq_4way
py_compare_baq_4way:
	python ./source_file/simulation/tb_BAQ_4way/py_version_compare.py

.PHONY: py_compare_baq_wrap
py_compare_baq_wrap:
	python ./source_file/simulation/tb_BAQ_wrap/py_version_compare.py

