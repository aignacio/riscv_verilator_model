# Helper function that recursively includes files given a directory and a
# pattern/suffix extensions
proc recglob { basedir pattern } {
  set dirlist [glob -nocomplain -directory $basedir -type d *]
  set findlist [glob -nocomplain -directory $basedir $pattern]
  foreach dir $dirlist {
    set reclist [recglob $dir $pattern]
    set findlist [concat $findlist $reclist]
  }
  return $findlist
}

# Helper function to find all subdirectories containing ".vh" files
proc findincludedir { basedir pattern } {
  set vhfiles [recglob $basedir $pattern]
  set vhdirs {}
  foreach match $vhfiles {
    lappend vhdirs [file dir $match]
  }
  set uniquevhdirs [lsort -unique $vhdirs]
  return $uniquevhdirs
}

# Create the diretory for IPs
file mkdir $ipdir

# Update the IP catalog
update_ip_catalog -rebuild

# Generate IP implementations. Vivado TCL emitted from Chisel Blackboxes
source ../ips/ips.tcl

# AR 58526 <http://www.xilinx.com/support/answers/58526.html>
set xci_files [get_files -all {*.xci}]
foreach xci_file $xci_files {
  set_property GENERATE_SYNTH_CHECKPOINT {false} -quiet $xci_file
}

# Get a list of IPs in the current design
set obj [get_ips]

# Generate target data for the included IPs in the design
generate_target all $obj

# Export the IP user files
export_ip_user_files -of_objects $obj -no_script -force

# Get the list of active source and constraint files
set obj [current_fileset]
