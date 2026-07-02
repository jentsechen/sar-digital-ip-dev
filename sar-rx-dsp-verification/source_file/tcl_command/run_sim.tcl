# run_sim.tcl — launch behavioral simulation and run to $finish.
# Invoked on an already-open project:  vivado <proj>.xpr -source run_sim.tcl
set_property -name {xsim.simulate.runtime} -value {-all} -objects [get_filesets sim_1]
launch_simulation
puts "==== behavioral simulation finished ===="
close_sim
