## set parameters
#set clk_p 3.333333333333333
 
#set max_input_delay [expr 0.1*$clk_p]
#set min_input_delay [expr 0.05*$clk_p]
#set max_output_delay [expr 0.1*$clk_p]
#set min_output_delay [expr 0.05*$clk_p]
 
## create clock
#create_clock -period $clk_p -name clk [get_ports clk]
 
## set input delay
#set_input_delay -clock clk -max $max_input_delay [all_inputs]
#set_input_delay -clock clk -min $min_input_delay [all_inputs] -add_delay
 
 
## set output delay
#set_output_delay -clock clk -max $max_output_delay [all_outputs]
#set_output_delay -clock clk -min $min_output_delay [all_outputs] -add_delay
 
