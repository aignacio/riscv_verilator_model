set scriptdir [file dirname [info script]]

# Create the and set working variables
source [file join $scriptdir "start.tcl"]

# Import all the RTL files
source [file join $scriptdir "import.tcl"]

# Initialize IPs building files
source [file join $scriptdir "prep_ips.tcl"]

# Synthesize the design
source [file join $scriptdir "synthesis.tcl"]

# Post synthesis optimization
source [file join $scriptdir "opt.tcl"]

# Place the design
source [file join $scriptdir "place.tcl"]

# Route the design
source [file join $scriptdir "route.tcl"]

# Generate bitstream and save verilog netlist
source [file join $scriptdir "bitstream.tcl"]

# Create reports for the current implementation
source [file join $scriptdir "report.tcl"]
