import os
import numpy as np
import matplotlib.pyplot as plt
# from py_BAQ_Code_Fast import B,OutputI_index,OutputQ_index,Ouput_block_headeriance
########################################################################
Block_parrallel = 4
sim_type = 1 #1:behavior 2:synth func
##############Compare lines##############################################
block_number = 50 #the number of block
compare_lines = 1600
compare_header_lines = 50
seq_compare_lines = compare_lines+4 #the header of golden & ver5 is 0
##############set_path##################################################
path_I1_golden = "/golden/BAQ_golden_I1.txt"
path_I2_golden = "/golden/BAQ_golden_I2.txt"
path_I3_golden = "/golden/BAQ_golden_I3.txt"
path_I4_golden = "/golden/BAQ_golden_I4.txt"
path_Q1_golden = "/golden/BAQ_golden_Q1.txt"
path_Q2_golden = "/golden/BAQ_golden_Q2.txt"
path_Q3_golden = "/golden/BAQ_golden_Q3.txt"
path_Q4_golden = "/golden/BAQ_golden_Q4.txt"
path_header_golden = "/golden/BAQ_golden_header.txt"

path_I1_out = "/output/BAQ_output_I1.txt"
path_I2_out = "/output/BAQ_output_I2.txt"
path_I3_out = "/output/BAQ_output_I3.txt"
path_I4_out = "/output/BAQ_output_I4.txt"
path_Q1_out = "/output/BAQ_output_Q1.txt"
path_Q2_out = "/output/BAQ_output_Q2.txt"
path_Q3_out = "/output/BAQ_output_Q3.txt"
path_Q4_out = "/output/BAQ_output_Q4.txt"
path_header_out = "/output/BAQ_output_header.txt"

##############Get location###############################################
local_py = (os.path.dirname(os.path.abspath(__file__)))
##############Function###################################################
def veri_read(location,out_lines):
    veri_out = []
    n = 0
    with open(location, 'r') as f:
        lines = f.readlines()
        for line in lines:
            line = line.strip('\n')
            veri_out.append(int(line))
            n = n + 1
            if n == out_lines:
                return veri_out

    return veri_out
##############Start to compare###########################################
#############Read file##################################################
BAQ_I1_golden = veri_read(local_py+path_I1_golden,compare_lines)
BAQ_I2_golden = veri_read(local_py+path_I2_golden,compare_lines)
BAQ_I3_golden = veri_read(local_py+path_I3_golden,compare_lines)
BAQ_I4_golden = veri_read(local_py+path_I4_golden,compare_lines)
BAQ_Q1_golden = veri_read(local_py+path_Q1_golden,compare_lines)
BAQ_Q2_golden = veri_read(local_py+path_Q2_golden,compare_lines)
BAQ_Q3_golden = veri_read(local_py+path_Q3_golden,compare_lines)
BAQ_Q4_golden = veri_read(local_py+path_Q4_golden,compare_lines)
BAQ_header_golden = veri_read(local_py+path_header_golden,compare_header_lines)

BAQ_I1_out = veri_read(local_py+path_I1_out,compare_lines)
BAQ_I2_out = veri_read(local_py+path_I2_out,compare_lines)
BAQ_I3_out = veri_read(local_py+path_I3_out,compare_lines)
BAQ_I4_out = veri_read(local_py+path_I4_out,compare_lines)
BAQ_Q1_out = veri_read(local_py+path_Q1_out,compare_lines)
BAQ_Q2_out = veri_read(local_py+path_Q2_out,compare_lines)
BAQ_Q3_out = veri_read(local_py+path_Q3_out,compare_lines)
BAQ_Q4_out = veri_read(local_py+path_Q4_out,compare_lines)
#############Start to compare###########################################
BAQ_I1_out = veri_read(local_py+path_I1_out,compare_lines)
BAQ_I2_out = veri_read(local_py+path_I2_out,compare_lines)
BAQ_I3_out = veri_read(local_py+path_I3_out,compare_lines)
BAQ_I4_out = veri_read(local_py+path_I4_out,compare_lines)
BAQ_Q1_out = veri_read(local_py+path_Q1_out,compare_lines)
BAQ_Q2_out = veri_read(local_py+path_Q2_out,compare_lines)
BAQ_Q3_out = veri_read(local_py+path_Q3_out,compare_lines)
BAQ_Q4_out = veri_read(local_py+path_Q4_out,compare_lines)
BAQ_header_out = veri_read(local_py+path_header_out,compare_header_lines)
BAQ_I_seq = []
BAQ_Q_seq = []
# ############################################################################################

for i in range(0,seq_compare_lines-3):
    if i%4==0:
        BAQ_I_seq = np.append(BAQ_I_seq,BAQ_I1_out[i//4])
    elif i%4 == 1:
        BAQ_I_seq = np.append(BAQ_I_seq,BAQ_I2_out[i//4])
    elif i%4 == 2:
        BAQ_I_seq = np.append(BAQ_I_seq,BAQ_I3_out[i//4])
    elif i%4 == 3:
        BAQ_I_seq = np.append(BAQ_I_seq,BAQ_I4_out[i//4])

    if i%4==0:
        BAQ_Q_seq = np.append(BAQ_Q_seq,BAQ_Q1_out[i//4])
    elif i%4 == 1:
        BAQ_Q_seq = np.append(BAQ_Q_seq,BAQ_Q2_out[i//4])
    elif i%4 == 2:
        BAQ_Q_seq = np.append(BAQ_Q_seq,BAQ_Q3_out[i//4])
    elif i%4 == 3:
        BAQ_Q_seq = np.append(BAQ_Q_seq,BAQ_Q4_out[i//4])
#################################################
##############Start to compare###########################################
BAQ_I1_golden = veri_read(local_py+path_I1_golden,compare_lines)
BAQ_I2_golden = veri_read(local_py+path_I2_golden,compare_lines)
BAQ_I3_golden = veri_read(local_py+path_I3_golden,compare_lines)
BAQ_I4_golden = veri_read(local_py+path_I4_golden,compare_lines)
BAQ_Q1_golden = veri_read(local_py+path_Q1_golden,compare_lines)
BAQ_Q2_golden = veri_read(local_py+path_Q2_golden,compare_lines)
BAQ_Q3_golden = veri_read(local_py+path_Q3_golden,compare_lines)
BAQ_Q4_golden = veri_read(local_py+path_Q4_golden,compare_lines)
BAQ_header_golden = veri_read(local_py+path_header_golden,compare_header_lines)

BAQ_I1_out_np = np.array(BAQ_I1_out)
BAQ_I2_out_np = np.array(BAQ_I2_out)
BAQ_I3_out_np = np.array(BAQ_I3_out)
BAQ_I4_out_np = np.array(BAQ_I4_out)
BAQ_Q1_out_np = np.array(BAQ_Q1_out)
BAQ_Q2_out_np = np.array(BAQ_Q2_out)
BAQ_Q3_out_np = np.array(BAQ_Q3_out)
BAQ_Q4_out_np = np.array(BAQ_Q4_out)

BAQ_I1_golden_np = np.array(BAQ_I1_golden)
BAQ_I2_golden_np = np.array(BAQ_I2_golden)
BAQ_I3_golden_np = np.array(BAQ_I3_golden)
BAQ_I4_golden_np = np.array(BAQ_I4_golden)
BAQ_Q1_golden_np = np.array(BAQ_Q1_golden)
BAQ_Q2_golden_np = np.array(BAQ_Q2_golden)
BAQ_Q3_golden_np = np.array(BAQ_Q3_golden)
BAQ_Q4_golden_np = np.array(BAQ_Q4_golden)

BAQ_I1_error = BAQ_I1_out_np - BAQ_I1_golden_np[0:1603]
BAQ_I2_error = BAQ_I2_out_np - BAQ_I2_golden_np[0:1603]
BAQ_I3_error = BAQ_I3_out_np - BAQ_I3_golden_np[0:1603]
BAQ_I4_error = BAQ_I4_out_np - BAQ_I4_golden_np[0:1603]
BAQ_Q1_error = BAQ_Q1_out_np - BAQ_Q1_golden_np[0:1603]
BAQ_Q2_error = BAQ_Q2_out_np - BAQ_Q2_golden_np[0:1603]
BAQ_Q3_error = BAQ_Q3_out_np - BAQ_Q3_golden_np[0:1603]
BAQ_Q4_error = BAQ_Q4_out_np - BAQ_Q4_golden_np[0:1603]

BAQ_total_error =   BAQ_I1_error+\
                    BAQ_I2_error+\
                    BAQ_I3_error+\
                    BAQ_I4_error+\
                    BAQ_Q1_error+\
                    BAQ_Q2_error+\
                    BAQ_Q3_error+\
                    BAQ_Q4_error
plt.figure()
BAQ_header_error = np.array(BAQ_header_out) - np.array(BAQ_header_golden)
error_x_axis = np.arange(0,compare_lines)
error_header_x_axis = np.arange(0,compare_header_lines)
plt.subplot(4, 1, 1) 
plt.stem(error_x_axis[0:1603],BAQ_total_error)
plt.title('total_error (golden VS Out)')
plt.xlabel('n_data*8')
plt.ylabel('Magnitude (unit:1)')
plt.show
plt.subplot(4, 1, 3) 
plt.stem(error_header_x_axis[0:1603],BAQ_header_error)
plt.title('total_header_error (golden VS Out)')
plt.xlabel('n_data')
plt.ylabel('Magnitude (unit:1)')
plt.show()