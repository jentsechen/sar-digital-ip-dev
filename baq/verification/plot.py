import json
import os
import matplotlib.pyplot as plt
import numpy as np

with open("build/input.json") as f:
    inp = json.load(f)
with open("build/output.json") as f:
    out = json.load(f)

I_in  = np.array(inp["I"])
Q_in  = np.array(inp["Q"])
I_out = np.array(out["I"])
Q_out = np.array(out["Q"])
n     = np.arange(len(I_in))

fig, axes = plt.subplots(3, 2, figsize=(12, 9))
fig.suptitle("BAQ Compression: Input vs Output")

for col, (label, x_in, x_out) in enumerate([("I", I_in, I_out), ("Q", Q_in, Q_out)]):
    ax = axes[0, col]
    ax.plot(n, x_in,  label="Input",  linewidth=0.8)
    ax.plot(n, x_out, label="Output", linewidth=0.8, linestyle="--")
    ax.set_title(f"{label} channel")
    ax.set_xlabel("Sample")
    ax.legend()
    ax.grid(True)

    ax = axes[1, col]
    ax.plot(n, x_in - x_out, linewidth=0.8, color="tab:red")
    ax.set_title(f"{label} error (input − output)")
    ax.set_xlabel("Sample")
    ax.grid(True)

    ax = axes[2, col]
    ax.scatter(x_in, x_out, s=2, alpha=0.5)
    ax.set_title(f"{label} scatter (input vs output)")
    ax.set_xlabel("Input")
    ax.set_ylabel("Output")
    ax.grid(True)

os.makedirs("../diagram", exist_ok=True)
plt.tight_layout()
plt.savefig("../diagram/baq_plot.png", dpi=150)
plt.show()
