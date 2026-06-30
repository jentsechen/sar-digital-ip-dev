#!/usr/bin/env bash
#==============================================================================
# run_compare.sh -- Run TestSarRxDsp against BOTH designs and diff the outputs.
#
#   genericLib  <- source_file/design/CmultImplGeneric    (tool-inferred mult)
#   dsp3Lib     <- source_file/design/CmultImpl3DspSlice   (3 DSP slices)
#
# Same testbench, same test pattern, two implementations. Each run exports its
# output vectors; we diff them. Identical => the two Cmult implementations are
# numerically equivalent for this pattern.
#
# Library selection is done purely with `xelab -L <lib>` (only one design's
# library is on the search path per run), so the unqualified `SarRxDsp dut(.*)`
# resolves unambiguously -- no Verilog config needed for this flow.
#
# Usage:  make compare      (or)   bash source_file/run_compare.sh
#==============================================================================
set -euo pipefail

VIVADO_SETTINGS=${VIVADO_SETTINGS:-/tools/Xilinx/Vivado/2022.2/settings64.sh}
REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

DESIGN=$REPO/source_file/design
TB=$REPO/source_file/testbench/TestSarRxDsp.sv
PAT=$REPO/source_file/test_pattern
RUN=$REPO/sim_run
RESULTS=$REPO/results

# Output files exported by the testbench (the things we compare).
OUTPUTS=(io_out_h_data_0_bin.txt io_out_h_rcf_out_data_0_bin.txt)

# (lib name, design folder) pairs.
LIBS=(genericLib dsp3Lib)
declare -A FOLDER=( [genericLib]=CmultImplGeneric [dsp3Lib]=CmultImpl3DspSlice )

source "$VIVADO_SETTINGS"

echo "### Preparing run dir: $RUN"
rm -rf "$RUN"; mkdir -p "$RUN"; cd "$RUN"
cp "$PAT"/*.txt .

echo "### Compiling testbench + glbl"
xvlog -sv "$TB"                                   > compile_tb.log   2>&1
xvlog "$XILINX_VIVADO/data/verilog/src/glbl.v"    > compile_glbl.log 2>&1

for lib in "${LIBS[@]}"; do
    echo "### Compiling ${FOLDER[$lib]} -> $lib"
    xvlog -work "$lib" "$DESIGN/${FOLDER[$lib]}"/*.v > "compile_$lib.log" 2>&1
done

for lib in "${LIBS[@]}"; do
    echo "### Run: $lib (${FOLDER[$lib]})"
    rm -f "${OUTPUTS[@]}"
    xelab -L "$lib" -L unisims_ver -L secureip --relax --debug off \
          work.TestSarRxDsp work.glbl -s "snap_$lib" > "elab_$lib.log" 2>&1
    xsim "snap_$lib" -runall > "sim_$lib.log" 2>&1
    # Surface FAILED checks if any
    if grep -q FAILED "sim_$lib.log"; then
        echo "  !! testbench reported FAILED for $lib (see $RUN/sim_$lib.log)"
    fi
    mkdir -p "$RESULTS/$lib"
    cp -f "${OUTPUTS[@]}" "$RESULTS/$lib/"
done

echo
echo "================ COMPARISON: generic vs dsp3 ================"
rc=0
for f in "${OUTPUTS[@]}"; do
    if diff -q "$RESULTS/genericLib/$f" "$RESULTS/dsp3Lib/$f" >/dev/null; then
        printf "  IDENTICAL : %s\n" "$f"
    else
        d=$(diff "$RESULTS/genericLib/$f" "$RESULTS/dsp3Lib/$f" | grep -c '^<' || true)
        printf "  DIFFER    : %s  (%s differing lines)\n" "$f" "$d"
        rc=1
    fi
done
echo "============================================================"
[ $rc -eq 0 ] && echo "RESULT: designs are numerically EQUIVALENT for this pattern." \
             || echo "RESULT: designs DIFFER (see $RESULTS/)."
exit $rc
