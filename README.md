# sar-rx-dsp-verification

## Run Vivado

Source the toolchain once per shell, then launch:

```bash
source /tools/Xilinx/Vivado/2022.2/settings64.sh
vivado &
```

## Build the project

```bash
make            # create the Vivado project (default target: gen_project)
make gui        # open the generated project in the Vivado GUI
make clean      # remove the generated project, logs, and .Xil/
```

## Layout

```
source_file/
├── tcl_command/    # project-creation Tcl
├── design/         # RTL design sources (.v/.sv)
├── testbench/      # testbench sources
└── test_pattern/   # test patterns / stimulus / expected data
```
