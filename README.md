# sar-rx-dsp-verification

Simulate the SAR Rx DSP (`SarRxDsp`) against a chosen complex-multiplier
implementation. Each design lives in its own folder under `source_file/design/`;
you pick which one to simulate with the `DESIGN` variable.

## Run Vivado

Source the toolchain once per shell, then launch:

```bash
source /tools/Xilinx/Vivado/2022.2/settings64.sh
vivado &
```

## Run a simulation (one line)

```bash
make sim DESIGN=CmultImplGeneric_SimTrue     # generate project + run behavioral sim
make sim DESIGN=CmultImpl3DspSlice_SimFalse  # a different design
make sim                                      # first design folder found (default)
```

`make sim` regenerates the project for the selected `DESIGN` and runs the
testbench (`TestSarRxDsp`) to `$finish`. Output vectors are written to the sim
run dir: `sar_rx_dsp_verification/sar_rx_dsp_verification.sim/sim_1/behav/xsim/`.

`DESIGN` is the folder name under `source_file/design/`. An invalid name prints
the list of available folders.

## Other make targets

```bash
make gen_project DESIGN=<folder>   # create the project only (no sim)
make gui                           # open the generated project in the Vivado GUI
make clean                         # remove the generated project, xsim.dir, logs
```

Switching `DESIGN` always regenerates the project — no `make clean` needed in
between. To simulate in the GUI, run `make gen_project DESIGN=<folder>` then
`make gui` and use **Flow Navigator → SIMULATION → Run Behavioral Simulation**.

## Layout

```
source_file/
├── tcl_command/    # main_project.tcl (create project), run_sim.tcl (launch sim)
├── design/         # one folder per design variant (selected via DESIGN=)
├── testbench/      # TestSarRxDsp.sv
└── test_pattern/   # io_*.txt stimulus vectors (auto-staged into the sim run dir)
```
