//==============================================================================
// cmp_cfg.v -- Verilog configurations for running TestSarRxDsp against EACH of
// the two designs (used by Vivado project / GUI simulation).
//
// TestSarRxDsp instantiates a single  SarRxDsp dut(.*);  but the project contains
// two libraries that both define module SarRxDsp (genericLib, dsp3Lib). These
// configs pick which one `dut` (and its whole subtree) binds to.
//
// Select one as the simulation top:
//   set_property top cfg_generic [get_filesets sim_1]   ;# generic Cmult
//   set_property top cfg_dsp3    [get_filesets sim_1]   ;# 3-DSP-slice Cmult
//
// (The command-line runner `make compare` does NOT need these — it controls the
//  library via xelab -L instead — but they make GUI simulation unambiguous.)
//==============================================================================
config cfg_generic;
  design xil_defaultlib.TestSarRxDsp;
  default liblist genericLib xil_defaultlib unisims_ver secureip;
endconfig

config cfg_dsp3;
  design xil_defaultlib.TestSarRxDsp;
  default liblist dsp3Lib xil_defaultlib unisims_ver secureip;
endconfig
