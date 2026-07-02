################# Project Setting###########################
## define target chip
# set part     "xczu67dr-fsve1156-2-i"
# set part     "xczu48dr-fsvg1517-2-e"
set part     "xczu49dr-ffvf1760-2-e"
## define target board
# set board_part "xilinx.com:zcu670:part0:2.0"
# set board_part "xilinx.com:zcu208:part0:2.0"
set board_part "xilinx.com:zcu216:part0:2.0"
## project name 
set projName "BFPQ_ip_prj"
## block design name
set bdName   "BFPQ_ip_prj" 

# hardware export 
set filePrefix   "BFPQ-fpga-v"
set vivadoVersion   "2022.2"

# defince hardware version
set pcb_ver     1
set major_ver   1
set minor_ver   0
set patch_ver   0

## synthesis strategy
set synth_stgy "Vivado Synthesis Defaults"
#   Option:[ Vivado Synthesis Defaults,
#   Flow_PerfOptimized_high]

## implementation strategy
set impl_stgy "Vivado Implementation Defaults"
#   Option:[ Vivado Implementation Defaults,  
#   Performance_EarlyBlockPlacement,
#   Performance_ExtraTimingOpt,
#   Performance_ExploreWithRemap,
#   Performance_ExplorePostRoutePhysOpt ]


################### Directories ###################################

# directories
namespace eval _tcl {
    proc get_script_folder {} {
        set script_path [file normalize [info script]]
        set script_folder [file dirname $script_path]
        return $script_folder
    }
}
variable script_folder
set script_folder [_tcl::get_script_folder]

# directories
set rootDir         "$script_folder/../../"
set projDir         "$rootDir/$projName"
set srcDir          "$rootDir/source_file"
set infDir          "$srcDir/interface"
set hardExDir       "$srcDir/hardware_export"
set constrDir       "$srcDir/constraint"
set commlibDir      "$rootDir/../../../commlib"
set projCommlibDir  "$rootDir/../../commlib"
