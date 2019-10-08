# Read the specified list of IP files
read_ip [glob -directory $ipdir [file join * {*.xci}]]

# Synthesize the design
synth_design -top $top -flatten_hierarchy $synth_mode -include_dirs $include_directories -verilog_define $defined_macros

# Checkpoint the current design
write_checkpoint -force [file join $wrkdir post_synth]
