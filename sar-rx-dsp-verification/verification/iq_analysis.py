import os
import numpy as np
import plotly.graph_objs as go
from plotly.subplots import make_subplots

# ---------------------------------------------------------------------------
# Merged IQ analysis for three simulation dumps. Every dump packs each 32-bit
# lane as {Q (high 16 bits), I (low 16 bits)}, with lane (n-1) first and lane 0
# last in the MSB-first bit string. Each row's parallel lanes are concatenated
# (lane 0 first) into one continuous I/Q stream, then plotted as I/Q subplots.
#
# Run once to regenerate all three HTML plots:
#     python iq_analysis.py
# ---------------------------------------------------------------------------

N_BITS = 16     # bits per I or per Q
PROJ_ROOT = os.path.dirname(os.path.dirname(__file__))
XSIM_DIR = os.path.join(PROJ_ROOT, "sar_rx_dsp_verification",
                        "sar_rx_dsp_verification.sim", "sim_1", "behav", "xsim")


def to_signed(bits, frac_bits):
    """N_BITS MSB-first binary string -> signed value scaled by 2^-frac_bits."""
    val = int(bits, 2)
    if val >= (1 << (N_BITS - 1)):
        val -= (1 << N_BITS)
    return val / (1 << frac_bits) if frac_bits else val


def parse_row(binary_str, frac_bits):
    """
    MSB-first binary string, layout (lane n-1 first, Q before I):
        Q[n-1] I[n-1] ... Q[1] I[1] Q[0] I[0]   (each I/Q = N_BITS bits)
    Returns the row's parallel samples in lane-0-first order
    [I[0]+jQ[0], I[1]+jQ[1], ...].
    """
    n_lane = len(binary_str) // (2 * N_BITS)
    samples = []
    for lane in range(n_lane):
        q_start = (n_lane - 1 - lane) * 2 * N_BITS   # high 16 bits of the lane = Q
        i_start = q_start + N_BITS                    # low 16 bits of the lane = I
        q = to_signed(binary_str[q_start:q_start + N_BITS], frac_bits)
        i = to_signed(binary_str[i_start:i_start + N_BITS], frac_bits)
        samples.append(complex(i, q))
    return samples


def read_bin_lines(path):
    """Rows are already MSB-first binary strings (one per line)."""
    with open(path) as f:
        return [l.strip() for l in f
                if l.strip() and set(l.strip()) <= {'0', '1'}]


def read_hex_col0(path):
    """Rows are whitespace-separated; column 0 is a hex value -> binary string."""
    rows = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            hex_str = line.split()[0]
            nbits = len(hex_str) * 4
            rows.append(format(int(hex_str, 16), f"0{nbits}b"))
    return rows


def analyze(name, filename, frac_bits, reader, title):
    """Load a dump, concatenate lanes into one stream, and write an HTML plot."""
    path = os.path.join(XSIM_DIR, filename)
    rows = reader(path)
    stream = np.array([s for r in rows for s in parse_row(r, frac_bits)])
    n_lane = len(parse_row(rows[0], frac_bits)) if rows else 0
    print(f"[{name}] {len(rows)} rows x {n_lane} lanes -> {len(stream)} samples "
          f"(FRAC_BITS={frac_bits})")

    fig = make_subplots(rows=2, cols=1, shared_xaxes=True,
                        subplot_titles=("I (real)", "Q (imag)"))
    fig.add_trace(go.Scatter(y=stream.real, name="I"), row=1, col=1)
    fig.add_trace(go.Scatter(y=stream.imag, name="Q"), row=2, col=1)
    fig.update_layout(title=title)

    out_html = os.path.join(os.path.dirname(__file__), f"{name}.html")
    fig.write_html(out_html)
    print(f"[{name}] plot saved to {out_html}")


# Per-dump configuration: (output name, input file, frac_bits, reader, title)
ANALYSES = [
    ("io_ind_h_data_0", "io_ind_h_data.txt", 15, read_hex_col0,
     "io_ind_h_data column 0 — concatenated IQ (16-bit int, Q0.15)"),
    ("io_out_h_data_0", "io_out_h_data_0_bin.txt", 12, read_bin_lines,
     "io_out_h_data_0 — IQ (Q3.12)"),
    ("io_out_h_rcf_out_data_0", "io_out_h_rcf_out_data_0_bin.txt", 15, read_bin_lines,
     "io_out_h_rcf_out_data_0 — IQ (Q0.15)"),
]


if __name__ == "__main__":
    for cfg in ANALYSES:
        analyze(*cfg)
