# SET PROJECT NAME
set  project_name Loongson_Soc
# Generate timestamp in format YYYY_MMDD_HHMM
set timestamp [clock format [clock seconds] -format "%Y_%m%d_%H%M"]
# Construct project path
set project_path "./project_${timestamp}"
puts "=> Project will be created at: $project_path"
set project_part xc7a200tfbg676-1
# CLEAR
file delete -force $project_path

create_project -force $project_name $project_path -part $project_part

# Add conventional sources
add_files -scan_for_includes ../rtl

# Add IPs
add_files -norecurse -scan_for_includes ../rtl/ip/PLL_2023_2/clk_pll.xci

# Add simulation files
add_files -fileset sim_1 ../sim/

# Add constraints
add_files -fileset constrs_1 -quiet ./constraints

set_property -name "top" -value "tb_top" -objects  [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
