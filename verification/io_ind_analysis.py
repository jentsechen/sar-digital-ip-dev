import os
import sys
import numpy as np
import plotly.graph_objs as go
from plotly.subplots import make_subplots

# ---------------------------------------------------------------------------
# Read the FIRST column of io_ind_h_data.txt, convert each value to binary,
# and interpret the bits (MSB-first) as PARALLEL samples of a single stream:
#
#     Q[4] I[4] Q[3] I[3] Q[2] I[2] Q[1] I[1] Q[0] I[0]   (each I/Q = 16-bit int)
#
# These are data parallelism (5 samples delivered per row), NOT separate
# channels -- so every row's samples are concatenated, lane 0 first, into one
# continuous I/Q time series.
# ---------------------------------------------------------------------------

N_BITS = 16        # bits per I or per Q
FRAC_BITS = 15     # Q0.15: 1 sign bit + 15 fractional bits
LANE0_FIRST = True  # within a row, is lane 0 (LSB) the earliest sample in time?

PROJ_ROOT = os.path.dirname(os.path.dirname(__file__))
DEFAULT_PATH = os.path.join(PROJ_ROOT,
                            "sar_rx_dsp_verification", "sar_rx_dsp_verification.sim",
                            "sim_1", "behav", "xsim", "io_ind_h_data.txt")


def to_signed(bits):
    """16-bit MSB-first binary string -> signed value (scaled by 2^-FRAC_BITS)."""
    val = int(bits, 2)
    if val >= (1 << (N_BITS - 1)):
        val -= (1 << N_BITS)
    return val / (1 << FRAC_BITS) if FRAC_BITS else val


def parse_row(binary_str):
    """
    MSB-first binary string, layout (lane n-1 first, Q before I):
        Q[n-1] I[n-1] ... Q[1] I[1] Q[0] I[0]
    Returns the row's parallel samples in time order
    [I[0]+jQ[0], I[1]+jQ[1], ...] (lane 0 first when LANE0_FIRST).
    """
    n_lane = len(binary_str) // (2 * N_BITS)
    samples = []
    for lane in range(n_lane):
        q_start = (n_lane - 1 - lane) * 2 * N_BITS
        i_start = q_start + N_BITS
        q = to_signed(binary_str[q_start:q_start + N_BITS])
        i = to_signed(binary_str[i_start:i_start + N_BITS])
        samples.append(complex(i, q))
    return samples if LANE0_FIRST else samples[::-1]


def hex_first_col_to_bin(hex_str):
    """First-column hex value -> zero-padded binary string (multiple of 16 bits)."""
    nbits = len(hex_str) * 4
    return format(int(hex_str, 16), f"0{nbits}b")


if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_PATH

    rows = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            rows.append(line.split()[0])       # whitespace-separated, column 0

    n_lane = (len(rows[0]) * 4) // (2 * N_BITS)
    print(f"Read {len(rows)} rows from {path}")
    print(f"Column-0 width = {len(rows[0]) * 4} bits => {n_lane} parallel samples/row "
          f"(I/Q = {N_BITS}-bit, FRAC_BITS={FRAC_BITS})")

    # Concatenate every row's parallel samples into ONE continuous stream.
    stream = np.array([s for h in rows for s in parse_row(hex_first_col_to_bin(h))])
    print(f"Concatenated into {len(stream)} samples "
          f"({n_lane} lanes x {len(rows)} rows)")

    # --- plot: single concatenated I (real) and Q (imag) time series ---
    fig = make_subplots(rows=2, cols=1, shared_xaxes=True,
                        subplot_titles=("I (real)", "Q (imag)"))
    fig.add_trace(go.Scatter(y=stream.real, name="I"), row=1, col=1)
    fig.add_trace(go.Scatter(y=stream.imag, name="Q"), row=2, col=1)
    fig.update_layout(title=f"io_ind_h_data column 0 — concatenated IQ "
                            f"({N_BITS}-bit int, {n_lane}-way parallel)")

    out_html = os.path.join(os.path.dirname(__file__), "io_ind_h_data_0.html")
    fig.write_html(out_html)
    print(f"Plot saved to {out_html}")
