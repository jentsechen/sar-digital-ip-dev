# configuration
source source_file/tcl_command/config.tcl

### create project
create_project $projName $projDir -part $part
current_project $projName

set_property BOARD_PART $board_part [current_project]
set_property strategy $synth_stgy [get_runs synth_1]
set_property strategy $impl_stgy [get_runs impl_1]
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]

source "$srcDir/tcl_command/include_design.tcl"

# Constrain
set xdc_files [list timing_constraint.xdc]

foreach file $xdc_files {
    add_files -fileset constrs_1 -norecurse "$srcDir/constraint/$file"
    puts "###### XDC IMPORT ##:$file"
}


set sim_files [list \
    [file normalize "$srcDir/simulation/tb_BFPQ_wrap.sv"] \
    [file normalize "$srcDir/simulation/BFPQ_tunable_4way_v2_tb.sv"] \
]
add_files -norecurse -fileset [get_filesets sim_1] $sim_files
set_property top tb_BFPQ_wrap [get_filesets sim_1]
# set_property top BAQ_top [current_fileset]


# # import block design
# create_bd_design $bdName
# set bck_tcl "$srcDir/tcl_command/$bdName.tcl"

# puts "###### Block Design ##: $bdName "

# if { [file exists $bck_tcl]==1 } {
#     source $bck_tcl
# } 
# create_root_design /

# # regenerate_bd_layout

# ### Make HDL wrapper
# make_wrapper -files [get_files $projDir/$projName.srcs/sources_1/bd/$bdName/$bdName.bd] -top
# add_files $projDir/$projName.srcs/sources_1/bd/$bdName/hdl/$bdName\_wrapper.v
# set_property top $bdName\_wrapper [current_fileset]
# save_bd_design
