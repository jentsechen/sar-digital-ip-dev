# main_project.tcl — create the Vivado project for the A/B Cmult comparison.
#
# Two implementations of SarRxDsp are compared in ONE testbench:
#   genericLib  <- source_file/design/CmultImplGeneric   (tool-inferred multipliers)
#   dsp3Lib     <- source_file/design/CmultImpl3DspSlice  (3 DSP slices per cmult)
#
# Both declare a module named SarRxDsp, so each goes into its OWN Verilog library
# and the testbench's two instances are bound per-library by dual_dut_cfg.v.
# The design files live in fileset sim_1 only (not sources_1) so synthesis has no
# duplicate-top ambiguity — this is a simulation/comparison project.
#
# Usage (driven by the Makefile):
#   vivado -mode batch -source main_project.tcl -tclargs <proj_name> <part>

set proj_name [lindex $argv 0]
set part      [lindex $argv 1]
if {$proj_name eq ""} { set proj_name "sar_rx_dsp_verification" }
if {$part eq ""}      { set part      "xczu48dr-fsvg1517-2-e" }

create_project $proj_name $proj_name -part $part -force

# --- helper: add a design folder's *.v into a named library (sim_1) ---
proc add_design_lib {folder lib} {
    set files [glob -nocomplain "$folder/*.v"]
    if {[llength $files] == 0} {
        puts "WARNING: no .v files found in $folder"
        return
    }
    add_files -fileset sim_1 -norecurse $files
    set_property library $lib [get_files -of_objects [get_filesets sim_1] $files]
    puts "Added [llength $files] files from $folder into library '$lib'"
}

add_design_lib source_file/design/CmultImplGeneric  genericLib
add_design_lib source_file/design/CmultImpl3DspSlice dsp3Lib

# --- testbench (default library xil_defaultlib) + per-design configs ---
add_files -fileset sim_1 -norecurse {
    source_file/testbench/TestSarRxDsp.sv
    source_file/testbench/cmp_cfg.v
}

# Test-pattern vectors (read by the TB at run time via $fopen).
add_files -fileset sim_1 -norecurse [glob -nocomplain source_file/test_pattern/*.txt]

# Simulation top is a CONFIG that binds the single SarRxDsp instance to ONE
# design library. Default to the generic build; switch to cfg_dsp3 for the other.
set_property top cfg_dsp3 [get_filesets sim_1]
# set_property top cfg_generic [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

update_compile_order -fileset sim_1

# Stage test-pattern vectors into the behavioral-sim run directory so the GUI
# "Run Behavioral Simulation" finds them (the TB opens them by relative path).
set sim_run_dir [file join [get_property DIRECTORY [current_project]] \
                           ${proj_name}.sim sim_1 behav xsim]
file mkdir $sim_run_dir
foreach f [glob -nocomplain source_file/test_pattern/*.txt] {
    file copy -force $f $sim_run_dir
}
puts "Staged test patterns into $sim_run_dir"

puts "Created project '$proj_name' (part '$part'); sim top = cfg_generic"
puts "To compare both designs from the shell: make compare"
