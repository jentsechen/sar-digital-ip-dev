import os
import numpy as np
import plotly.graph_objs as go
from plotly.subplots import make_subplots

PROJ_ROOT = os.path.dirname(os.path.dirname(__file__))
TXT_PATH = os.path.join(PROJ_ROOT,
                        "sar_rx_dsp_verification", "sar_rx_dsp_verification.sim",
                        "sim_1", "behav", "xsim", "io_ind_aaf_data.txt")

N_LSB = 28      # data is 28 bits wide (AAF_FREQ_RESP_WIDTH)
N_BITS = 14     # bits per I or Q (raw signed integer, no fractional scaling)

# ---- Bit-reversal reorder (configurable) ----
BIT_REVERSE = False    # set False to keep natural sample order
BLOCK_SIZE = 256      # samples per block; reversal is applied within each block (must be power of 2)


def bit_reverse_indices(n):
    """Return the bit-reversal permutation of length n (n must be a power of 2)."""
    if n & (n - 1) != 0:
        raise ValueError(f"BLOCK_SIZE must be a power of 2, got {n}")
    n_bits = n.bit_length() - 1
    return [int(format(i, f"0{n_bits}b")[::-1], 2) for i in range(n)]


def bit_reverse_reorder(arr, block):
    """Reorder each consecutive `block`-sample chunk into bit-reversed order.
    Any trailing samples that don't fill a full block are left in place."""
    arr = np.asarray(arr)
    perm = bit_reverse_indices(block)
    out = arr.copy()
    n_full = len(arr) // block
    if len(arr) % block:
        print(f"[warn] {len(arr) % block} trailing samples do not fill a full "
              f"block of {block}; leaving them in natural order")
    for b in range(n_full):
        s = b * block
        out[s:s + block] = arr[s:s + block][perm]
    return out


def to_signed(val, nbits):
    """Interpret the low `nbits` of `val` as a two's-complement signed integer."""
    val &= (1 << nbits) - 1
    if val >= (1 << (nbits - 1)):
        val -= (1 << nbits)
    return val


def parse_row(hex_str):
    """
    Each line is a hex value; take the low 28 bits and split into two
    14-bit two's-complement signed fields:  Q[13:0] (upper 14)  I[13:0] (lower 14).
    """
    word = int(hex_str, 16) & ((1 << N_LSB) - 1)
    i = to_signed(word & ((1 << N_BITS) - 1), N_BITS)
    q = to_signed((word >> N_BITS) & ((1 << N_BITS) - 1), N_BITS)
    return i, q


if __name__ == "__main__":
    with open(TXT_PATH) as f:
        lines = [l.strip() for l in f if l.strip()]

    i_vals, q_vals = [], []
    for line in lines:
        i, q = parse_row(line)
        i_vals.append(i)
        q_vals.append(q)
    i_vals = np.array(i_vals, dtype=np.int64)
    q_vals = np.array(q_vals, dtype=np.int64)
    print(f"Parsed {len(i_vals)} samples")

    if BIT_REVERSE:
        i_vals = bit_reverse_reorder(i_vals, BLOCK_SIZE)
        q_vals = bit_reverse_reorder(q_vals, BLOCK_SIZE)
        print(f"Applied bit-reversal reorder in blocks of {BLOCK_SIZE}")

    i_sq = i_vals ** 2
    q_sq = q_vals ** 2

    fig = make_subplots(rows=2, cols=1, shared_xaxes=True,
                        subplot_titles=("I^2", "Q^2"))
    fig.add_trace(go.Scatter(y=i_sq, name="I^2", mode="lines"), row=1, col=1)
    fig.add_trace(go.Scatter(y=q_sq, name="Q^2", mode="lines"), row=2, col=1)
    fig.update_layout(title="io_ind_aaf_data — I^2 and Q^2 (14-bit signed I/Q)",
                      xaxis2_title="sample")

    out_html = os.path.join(os.path.dirname(__file__), "io_ind_aaf_data.html")
    fig.write_html(out_html)
    print(f"Plot saved to {out_html}")
