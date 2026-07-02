namespace eval _tcl {
    proc get_script_folder {} {
        set script_path [file normalize [info script]]
        set script_folder [file dirname $script_path]
        return $script_folder
    }
    proc main {} {
        # find script folder
        variable script_folder
        set script_folder [_tcl::get_script_folder]

        # set related directories
        set rootDir     "$script_folder/../../"
        set srcDir      "$rootDir/source_file"
        set infDir      "$srcDir/interface"
        set commlibDir  "$rootDir/../../../commlib"

        ################### Import Source ###################################
        ##Import all .v file in design folder
        set obj [get_filesets sources_1]
        set files [glob $srcDir/design/*]
        add_files -norecurse -fileset $obj $files

        # import IP
        # source "$commlibDir/vivado/axi_lite_to_sp_ip/source_file/tcl_command/include_design.tcl"
        # source "$commlibDir/vivado/bram_rtl_ip/source_file/tcl_command/include_design.tcl"


        ### FPGA_Board include source begin

        set existing_paths [get_property ip_repo_paths [current_project]]
        lappend existing_paths $infDir
        set_property ip_repo_paths $existing_paths [current_project]

        update_ip_catalog -rebuild

        # Get a list of all added files
        set added_files [get_files -of_objects [get_filesets sources_1]]
        # Print the list of added files
        foreach file $added_files {
            puts "###### IP  IMPORT ##:[file tail $file]"
        }
        ## Xilinx IP
        # create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_cmd
        # set_property -dict [list CONFIG.Component_Name {axis_register_slice_cmd} CONFIG.HAS_TLAST {1} CONFIG.TDATA_NUM_BYTES {90} CONFIG.TUSER_WIDTH {16}] [get_ips axis_register_slice_cmd]
        # set_property generate_synth_checkpoint false [get_files axis_register_slice_cmd.xci]
        create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_BFPQ_out_fifo
        set_property -dict [list \
        CONFIG.Component_Name {axis_BFPQ_out_fifo} \
        CONFIG.FIFO_DEPTH {16} \
        CONFIG.HAS_PROG_FULL {1} \
        CONFIG.TDATA_NUM_BYTES {16} \
        ] [get_ips axis_BFPQ_out_fifo]
        set_property generate_synth_checkpoint false [get_files axis_BFPQ_out_fifo.xci]

        create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name bfpq_tlast_fifo
        set_property -dict [list \
        CONFIG.Component_Name {bfpq_tlast_fifo} \
        CONFIG.Fifo_Implementation {Common_Clock_Distributed_RAM} \
        CONFIG.Input_Data_Width {1} \
        CONFIG.Input_Depth {32} \
        CONFIG.Performance_Options {First_Word_Fall_Through} \
        ] [get_ips bfpq_tlast_fifo]
        set_property generate_synth_checkpoint false [get_files bfpq_tlast_fifo.xci]

    }
}
_tcl::main