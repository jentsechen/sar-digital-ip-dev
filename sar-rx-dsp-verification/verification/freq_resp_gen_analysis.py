import os
import numpy as np
import plotly.graph_objs as go

PROJ_ROOT = os.path.dirname(os.path.dirname(__file__))
TXT_PATH = os.path.join(PROJ_ROOT,
                        "sar_rx_dsp_verification", "sar_rx_dsp_verification.sim",
                        "sim_1", "behav", "xsim", "freq_resp_gen_out_axis_data.txt")

N_LSB = 28      # only the low 28 bits carry data
N_BITS = 14     # bits per I or Q (raw signed integer, no fractional scaling)

# ---- Bit-reversal reorder (configurable) ----
BIT_REVERSE = True    # set False to keep natural sample order
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


def to_signed(bits):
    val = int(bits, 2)
    if val >= (1 << (N_BITS - 1)):
        val -= (1 << N_BITS)
    return val


def parse_row(binary_str):
    """
    Take the low 28 bits (LSB) of the MSB-first binary string.
    Layout of those 28 bits:  Q[13:0] I[13:0]  (Q upper 14, I lower 14).
    Q and I are raw 14-bit two's-complement integers.
    """
    lsb = binary_str[-N_LSB:]
    q = to_signed(lsb[0:N_BITS])
    i = to_signed(lsb[N_BITS:2 * N_BITS])
    return i, q


if __name__ == "__main__":
    with open(TXT_PATH) as f:
        lines = [l.strip() for l in f if l.strip() and set(l.strip()) <= {'0', '1'}]

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

    mag = i_vals ** 2 + q_vals ** 2

    fig = go.Figure()
    fig.add_trace(go.Scatter(y=mag, name="I^2 + Q^2", mode="lines"))
    fig.update_layout(title="freq_resp_gen out AXIS — magnitude (I^2 + Q^2)",
                      xaxis_title="sample", yaxis_title="I^2 + Q^2")

    out_html = os.path.join(os.path.dirname(__file__), "freq_resp_gen_out_axis_data.html")
    fig.write_html(out_html)
    print(f"Plot saved to {out_html}")
