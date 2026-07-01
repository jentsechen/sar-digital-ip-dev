import os
import numpy as np
import plotly.graph_objs as go
from plotly.subplots import make_subplots

PROJ_ROOT = os.path.dirname(os.path.dirname(__file__))
TXT_PATH = os.path.join(PROJ_ROOT,
                        "sar_rx_dsp_verification", "sar_rx_dsp_verification.sim",
                        "sim_1", "behav", "xsim", "io_out_h_rcf_out_data_0_bin.txt")

N_BITS = 16     # bits per I or Q
N_CH = 4        # channels 0-3
FRAC_BITS = 15  # 1 sign + 15 fractional (Q0.15)


def to_signed(bits):
    val = int(bits, 2)
    if val >= (1 << (N_BITS - 1)):
        val -= (1 << N_BITS)
    return val / (1 << FRAC_BITS)


def parse_row(binary_str):
    """
    128-bit MSB-first binary string, layout:
      Q[3] I[3] Q[2] I[2] Q[1] I[1] Q[0] I[0]  (each 16 bits)

    Returns [I[0]+jQ[0], I[1]+jQ[1], I[2]+jQ[2], I[3]+jQ[3]].
    """
    result = []
    for ch in range(N_CH):
        q_start = (3 - ch) * 2 * N_BITS
        i_start = q_start + N_BITS
        q = to_signed(binary_str[q_start : q_start + N_BITS])
        i = to_signed(binary_str[i_start : i_start + N_BITS])
        result.append(complex(i, q))
    return result


if __name__ == "__main__":
    with open(TXT_PATH) as f:
        lines = [l.strip() for l in f if l.strip() and set(l.strip()) <= {'0', '1'}]

    data = []
    for line in lines:
        data.extend(parse_row(line))
    data = np.array(data)
    print(f"Parsed {len(data)} complex samples ({N_CH} ch × {len(lines)} rows)")

    fig = make_subplots(rows=2, cols=1, shared_xaxes=True,
                        subplot_titles=("I (real)", "Q (imag)"))
    fig.add_trace(go.Scatter(y=data.real, name="I"), row=1, col=1)
    fig.add_trace(go.Scatter(y=data.imag, name="Q"), row=2, col=1)
    fig.update_layout(title="io_out_h_rcf_out_data_0 — IQ (Q0.15)")

    out_html = os.path.join(os.path.dirname(__file__), "io_out_h_rcf_out_data_0.html")
    fig.write_html(out_html)
    print(f"Plot saved to {out_html}")
