# main_project.tcl — create a Vivado project to simulate ONE selected design.
#
# The design to run is chosen by folder name under source_file/design/:
#   CmultImplGeneric    (tool-inferred multipliers)
#   CmultImpl3DspSlice  (3 DSP slices per complex multiply)
#
# Only one design is added, so there is no SarRxDsp name collision and no
# library/config is needed — the testbench top (TestSarRxDsp) is the sim top.
#
# Usage (driven by the Makefile):
#   vivado -mode batch -source main_project.tcl -tclargs <proj_name> <part> <design_folder>

set proj_name [lindex $argv 0]
set part      [lindex $argv 1]
set design    [lindex $argv 2]
if {$proj_name eq ""} { set proj_name "sar_rx_dsp_verification" }
if {$part eq ""}      { set part      "xczu48dr-fsvg1517-2-e" }
if {$design eq ""} {
    set design [lindex [lsort [glob -nocomplain -tails -directory source_file/design -type d *]] 0]
}

set design_dir "source_file/design/$design"
if {![file isdirectory $design_dir]} {
    set avail [lsort [glob -nocomplain -tails -directory source_file/design -type d *]]
    error "design folder not found: '$design'\n  available folders (pass DESIGN=<folder>):\n    [join $avail "\n    "]"
}

create_project $proj_name $proj_name -part $part -force

# --- design under test (single design -> default library xil_defaultlib) ---
set dfiles [glob -nocomplain "$design_dir/*.v"]
if {[llength $dfiles] == 0} { error "no .v files in $design_dir" }
add_files -norecurse $dfiles
puts "Design under simulation: $design ([llength $dfiles] files)"

# --- testbench + test-pattern vectors ---
add_files -fileset sim_1 -norecurse source_file/testbench/TestSarRxDsp.sv
add_files -fileset sim_1 -norecurse [glob -nocomplain source_file/test_pattern/*.txt]

set_property top TestSarRxDsp [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

# Stage test patterns into the behavioral-sim run dir (TB opens them by
# relative path from the simulator's working directory).
set sim_run_dir [file join [get_property DIRECTORY [current_project]] \
                           ${proj_name}.sim sim_1 behav xsim]
file mkdir $sim_run_dir
foreach f [glob -nocomplain source_file/test_pattern/*.txt] {
    file copy -force $f $sim_run_dir
}

puts "Created project '$proj_name' (part '$part'); design=$design; sim top = TestSarRxDsp"
