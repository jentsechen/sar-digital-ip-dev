"""Generate io_ind_aaf_data.txt from coef_256_fx.json.

Each coefficient is scaled by 2^SCALE_BITS, rounded, and packed as a 28-bit
word {im[13:0], re[13:0]} (im = high 14 bits, re = low 14 bits), written one
hex value per line -- the format the testbench reads with $fscanf("%h").
"""
import os
import json
import numpy as np

HERE = os.path.dirname(__file__)
PROJ_ROOT = os.path.dirname(HERE)
JSON_PATH = os.path.join(HERE, "coef_256_fx.json")
OUT_PATH = os.path.join(PROJ_ROOT, "source_file", "test_pattern", "io_ind_aaf_data.txt")

SCALE_BITS = 12   # multiply by 2^12
N_BITS = 14       # bits per re or im field (two's complement)
ROW = 0           # use row 0 of the [2][2048] arrays


def to_field(x):
    """Scale by 2^SCALE_BITS, round to nearest int, and return the N_BITS-wide
    two's-complement bit pattern (raises if out of range)."""
    v = int(np.round(x * (1 << SCALE_BITS)))
    lo, hi = -(1 << (N_BITS - 1)), (1 << (N_BITS - 1)) - 1
    if not (lo <= v <= hi):
        raise ValueError(f"value {x} -> {v} out of {N_BITS}-bit signed range [{lo},{hi}]")
    return v & ((1 << N_BITS) - 1)


if __name__ == "__main__":
    d = json.load(open(JSON_PATH))
    re = d["re"][ROW]
    im = d["im"][ROW]
    assert len(re) == len(im), "re/im length mismatch"

    lines = []
    for r, i in zip(re, im):
        word = (to_field(i) << N_BITS) | to_field(r)   # {im, re}
        lines.append(f"{word:07x}")

    with open(OUT_PATH, "w") as f:
        f.write("\n".join(lines) + "\n")
    print(f"Wrote {len(lines)} coefficients to {OUT_PATH}")
