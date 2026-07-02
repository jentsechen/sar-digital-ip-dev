import os
import numpy as np
import matplotlib.pyplot as plt
# from py_BFPQ_Code_Fast import B,OutputI_index,OutputQ_index,Ouput_block_variance
########################################################################
Block_parrallel = 4
sim_type = 1 #1:behavior 2:synth func
##############Compare lines##############################################
block_number = 64 #the number of block
compare_lines = 512
compare_var_lines = block_number
seq_compare_lines = compare_lines+4 #the header of golden & ver5 is 0
##############set_path##################################################
path_I1_golden = "/golden/BFPQ_golden_I1.txt"
path_I2_golden = "/golden/BFPQ_golden_I2.txt"
path_I3_golden = "/golden/BFPQ_golden_I3.txt"
path_I4_golden = "/golden/BFPQ_golden_I4.txt"
path_Q1_golden = "/golden/BFPQ_golden_Q1.txt"
path_Q2_golden = "/golden/BFPQ_golden_Q2.txt"
path_Q3_golden = "/golden/BFPQ_golden_Q3.txt"
path_Q4_golden = "/golden/BFPQ_golden_Q4.txt"
path_var_golden = "/golden/BFPQ_golden_header.txt"

path_I1_out = "/output/BFPQ_output_I1.txt"
path_I2_out = "/output/BFPQ_output_I2.txt"
path_I3_out = "/output/BFPQ_output_I3.txt"
path_I4_out = "/output/BFPQ_output_I4.txt"
path_Q1_out = "/output/BFPQ_output_Q1.txt"
path_Q2_out = "/output/BFPQ_output_Q2.txt"
path_Q3_out = "/output/BFPQ_output_Q3.txt"
path_Q4_out = "/output/BFPQ_output_Q4.txt"
path_var_out = "/output/BFPQ_output_header.txt"

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
BFPQ_I1_golden = veri_read(local_py+path_I1_golden,compare_lines)
BFPQ_I2_golden = veri_read(local_py+path_I2_golden,compare_lines)
BFPQ_I3_golden = veri_read(local_py+path_I3_golden,compare_lines)
BFPQ_I4_golden = veri_read(local_py+path_I4_golden,compare_lines)
BFPQ_Q1_golden = veri_read(local_py+path_Q1_golden,compare_lines)
BFPQ_Q2_golden = veri_read(local_py+path_Q2_golden,compare_lines)
BFPQ_Q3_golden = veri_read(local_py+path_Q3_golden,compare_lines)
BFPQ_Q4_golden = veri_read(local_py+path_Q4_golden,compare_lines)
BFPQ_var_golden = veri_read(local_py+path_var_golden,compare_var_lines)

BFPQ_I1_out = veri_read(local_py+path_I1_out,compare_lines)
BFPQ_I2_out = veri_read(local_py+path_I2_out,compare_lines)
BFPQ_I3_out = veri_read(local_py+path_I3_out,compare_lines)
BFPQ_I4_out = veri_read(local_py+path_I4_out,compare_lines)
BFPQ_Q1_out = veri_read(local_py+path_Q1_out,compare_lines)
BFPQ_Q2_out = veri_read(local_py+path_Q2_out,compare_lines)
BFPQ_Q3_out = veri_read(local_py+path_Q3_out,compare_lines)
BFPQ_Q4_out = veri_read(local_py+path_Q4_out,compare_lines)
#############Start to compare###########################################
BFPQ_I1_out = veri_read(local_py+path_I1_out,compare_lines)
BFPQ_I2_out = veri_read(local_py+path_I2_out,compare_lines)
BFPQ_I3_out = veri_read(local_py+path_I3_out,compare_lines)
BFPQ_I4_out = veri_read(local_py+path_I4_out,compare_lines)
BFPQ_Q1_out = veri_read(local_py+path_Q1_out,compare_lines)
BFPQ_Q2_out = veri_read(local_py+path_Q2_out,compare_lines)
BFPQ_Q3_out = veri_read(local_py+path_Q3_out,compare_lines)
BFPQ_Q4_out = veri_read(local_py+path_Q4_out,compare_lines)
BFPQ_var_out = veri_read(local_py+path_var_out,compare_var_lines)
BFPQ_I_seq = []
BFPQ_Q_seq = []
# ############################################################################################

for i in range(0,seq_compare_lines-3):
    if i%4==0:
        BFPQ_I_seq = np.append(BFPQ_I_seq,BFPQ_I1_out[i//4])
    elif i%4 == 1:
        BFPQ_I_seq = np.append(BFPQ_I_seq,BFPQ_I2_out[i//4])
    elif i%4 == 2:
        BFPQ_I_seq = np.append(BFPQ_I_seq,BFPQ_I3_out[i//4])
    elif i%4 == 3:
        BFPQ_I_seq = np.append(BFPQ_I_seq,BFPQ_I4_out[i//4])

    if i%4==0:
        BFPQ_Q_seq = np.append(BFPQ_Q_seq,BFPQ_Q1_out[i//4])
    elif i%4 == 1:
        BFPQ_Q_seq = np.append(BFPQ_Q_seq,BFPQ_Q2_out[i//4])
    elif i%4 == 2:
        BFPQ_Q_seq = np.append(BFPQ_Q_seq,BFPQ_Q3_out[i//4])
    elif i%4 == 3:
        BFPQ_Q_seq = np.append(BFPQ_Q_seq,BFPQ_Q4_out[i//4])
#################################################
##############Start to compare###########################################
BFPQ_I1_golden = veri_read(local_py+path_I1_golden,compare_lines)
BFPQ_I2_golden = veri_read(local_py+path_I2_golden,compare_lines)
BFPQ_I3_golden = veri_read(local_py+path_I3_golden,compare_lines)
BFPQ_I4_golden = veri_read(local_py+path_I4_golden,compare_lines)
BFPQ_Q1_golden = veri_read(local_py+path_Q1_golden,compare_lines)
BFPQ_Q2_golden = veri_read(local_py+path_Q2_golden,compare_lines)
BFPQ_Q3_golden = veri_read(local_py+path_Q3_golden,compare_lines)
BFPQ_Q4_golden = veri_read(local_py+path_Q4_golden,compare_lines)
BFPQ_var_golden = veri_read(local_py+path_var_golden,compare_var_lines)

BFPQ_I1_out_np = np.array(BFPQ_I1_out)
BFPQ_I2_out_np = np.array(BFPQ_I2_out)
BFPQ_I3_out_np = np.array(BFPQ_I3_out)
BFPQ_I4_out_np = np.array(BFPQ_I4_out)
BFPQ_Q1_out_np = np.array(BFPQ_Q1_out)
BFPQ_Q2_out_np = np.array(BFPQ_Q2_out)
BFPQ_Q3_out_np = np.array(BFPQ_Q3_out)
BFPQ_Q4_out_np = np.array(BFPQ_Q4_out)

BFPQ_I1_golden_np = np.array(BFPQ_I1_golden)
BFPQ_I2_golden_np = np.array(BFPQ_I2_golden)
BFPQ_I3_golden_np = np.array(BFPQ_I3_golden)
BFPQ_I4_golden_np = np.array(BFPQ_I4_golden)
BFPQ_Q1_golden_np = np.array(BFPQ_Q1_golden)
BFPQ_Q2_golden_np = np.array(BFPQ_Q2_golden)
BFPQ_Q3_golden_np = np.array(BFPQ_Q3_golden)
BFPQ_Q4_golden_np = np.array(BFPQ_Q4_golden)

BFPQ_I1_error = BFPQ_I1_out_np - BFPQ_I1_golden_np[0:1603]
BFPQ_I2_error = BFPQ_I2_out_np - BFPQ_I2_golden_np[0:1603]
BFPQ_I3_error = BFPQ_I3_out_np - BFPQ_I3_golden_np[0:1603]
BFPQ_I4_error = BFPQ_I4_out_np - BFPQ_I4_golden_np[0:1603]
BFPQ_Q1_error = BFPQ_Q1_out_np - BFPQ_Q1_golden_np[0:1603]
BFPQ_Q2_error = BFPQ_Q2_out_np - BFPQ_Q2_golden_np[0:1603]
BFPQ_Q3_error = BFPQ_Q3_out_np - BFPQ_Q3_golden_np[0:1603]
BFPQ_Q4_error = BFPQ_Q4_out_np - BFPQ_Q4_golden_np[0:1603]

BFPQ_total_error =   BFPQ_I1_error+\
                    BFPQ_I2_error+\
                    BFPQ_I3_error+\
                    BFPQ_I4_error+\
                    BFPQ_Q1_error+\
                    BFPQ_Q2_error+\
                    BFPQ_Q3_error+\
                    BFPQ_Q4_error
plt.figure()
BFPQ_var_error = np.array(BFPQ_var_out) - np.array(BFPQ_var_golden)
error_x_axis = np.arange(0,compare_lines)
error_var_x_axis = np.arange(0,compare_var_lines)
plt.subplot(4, 1, 1) 
plt.stem(error_x_axis[0:1603],BFPQ_total_error)
plt.title('total data error (golden VS output)')
plt.xlabel('data_sapmle(block_num * block_size_sample * pri)')
plt.ylabel('Magnitude (unit:1)')
plt.show
plt.subplot(4, 1, 3) 
plt.stem(error_var_x_axis[0:1603],BFPQ_var_error)
plt.title('total header error (golden VS output)')
plt.xlabel('header_sample(block_num * pri)')
plt.ylabel('Magnitude (unit:1)')
plt.show()