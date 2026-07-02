from typing import Literal
import numpy as np
import time
import matplotlib.pyplot as plt
import scipy.signal as signal
import csv
import plotly.graph_objs as go
import plotly.offline as pof
from plotly.subplots import make_subplots
import json
import numpy as np
import random
from enum import Enum, auto
import os

if __name__ == "__main__":
    font_size = 20
    # figure = make_subplots(rows=2, cols=1)
    # with open("./waveform.json", "r", encoding="UTF-8") as f:
    #     waveform = json.load(f)
    # with open("./sim_setting_exp.json", "r", encoding="UTF-8") as f:
    #     sim_setting_exp = json.load(f)
    # sim_setting = sim_setting_exp
    # sim_setting["I"] = waveform["re"]
    # sim_setting["Q"] = waveform["im"]
    # with open("sim_setting.json", "w", encoding="UTF-8") as f:
    #     json.dump(sim_setting, f)
    # figure.add_trace(go.Scatter(y=waveform["re"], name="re.", line_width=3), row=1, col=1)
    # figure.add_trace(go.Scatter(y=waveform["im"], name="im.", line_width=3), row=2, col=1)
    # figure.update_xaxes(title_text="sample",
    #                     title_font_size=font_size,
    #                     tickfont_size=font_size)
    # figure.update_yaxes(tickfont_size=font_size)
    # figure.update_layout(legend=dict(font=dict(size=font_size)))
    # # pof.iplot(figure)

    figure = make_subplots(rows=2, cols=1)
    with open("./baq_b128_w4.json", "r", encoding="UTF-8") as f:
        baq_b128_w4 = json.load(f)
    with open("./bfpq_b32_w4.json", "r", encoding="UTF-8") as f:
        bfpq_b32_w4 = json.load(f)
    with open("./sim_setting_exp.json", "r", encoding="UTF-8") as f:
        sim_setting_exp = json.load(f)
    figure.add_trace(go.Scatter(y=sim_setting_exp["input"]["I"], name="re.", line_width=3), row=1, col=1)
    figure.add_trace(go.Scatter(y=sim_setting_exp["input"]["Q"], name="im.", line_width=3), row=2, col=1)
    figure.add_trace(go.Scatter(y=baq_b128_w4["re"], name="re.", line_width=3), row=1, col=1)
    figure.add_trace(go.Scatter(y=baq_b128_w4["im"], name="im.", line_width=3), row=2, col=1)
    figure.add_trace(go.Scatter(y=bfpq_b32_w4["re"], name="re.", line_width=3), row=1, col=1)
    figure.add_trace(go.Scatter(y=bfpq_b32_w4["im"], name="im.", line_width=3), row=2, col=1)
    figure.update_xaxes(title_text="sample",
                        title_font_size=font_size,
                        tickfont_size=font_size)
    figure.update_yaxes(tickfont_size=font_size)
    figure.update_layout(legend=dict(font=dict(size=font_size)))
    pof.iplot(figure)