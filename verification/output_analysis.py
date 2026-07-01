import os
import json
import numpy as np
import plotly.graph_objs as go
from plotly.subplots import make_subplots

PROJ_ROOT = os.path.dirname(os.path.dirname(__file__))
JSON_PATH = os.path.join(PROJ_ROOT, "output.json")

N_CH = 4  # channels 0-3


if __name__ == "__main__":
    with open(JSON_PATH) as f:
        d = json.load(f)

    re = np.array(d["re"])
    im = np.array(d["im"])
    data = re + 1j * im
    print(f"Loaded output.json with shape {data.shape}")

    # Axis-1 index 0 carries the data; axis-2 holds N_CH parallel samples
    # per cycle, so flatten them into one continuous stream.
    iq = data[:, 0, :].reshape(-1)  # (n_rows * N_CH,)
    print(f"Concatenated {len(iq)} complex samples")

    fig = make_subplots(rows=2, cols=1, shared_xaxes=True,
                        subplot_titles=("I (real)", "Q (imag)"))
    fig.add_trace(go.Scatter(y=iq.real, name="I"), row=1, col=1)
    fig.add_trace(go.Scatter(y=iq.imag, name="Q"), row=2, col=1)
    fig.update_layout(title="output.json — IQ (parallel samples concatenated)")

    out_html = os.path.join(os.path.dirname(__file__), "output.html")
    fig.write_html(out_html)
    print(f"Plot saved to {out_html}")
