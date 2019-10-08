puts "Adding tcl of IPs into the project..."

set obj [current_fileset -constrset]

add_files -quiet -norecurse -fileset $obj [lsort [glob -directory ../ips -nocomplain {*.tcl}]]

puts "Adding files into the project..."

set constraints_dir [file join ../constraints/ $part]

set obj [current_fileset -constrset]

puts "-----> Adding constraints files (.xdc)..."

add_files -quiet -norecurse -fileset $obj [lsort [glob -directory $constraints_dir -nocomplain {*.xdc}]]

set obj [current_fileset]

puts "-----> Adding system/verilog files (.sv,.v)..."

# Add verilog files standalone
proc load_vsrc {obj vsrc_files} {
    foreach var $vsrc_files {
        puts "    -> Adding $var"
    }
    add_files -norecurse -fileset $obj $vsrc_files
}

# Add verilog files from manifest
proc load_vsrc_manifest {obj vsrc_manifest} {
    # For each manifest file (.F) do
    foreach manifest_file $vsrc_manifest {
        set abs_files {}
        # Reads the manifest file for get all .v or .sv
        set fp_verilog_files [open $manifest_file r]
        # Convert .v .sv into a list
        set files [lsearch -not -exact -all -inline [split [read $fp_verilog_files] "\n"] {}]
        # Get the dir of the manifest file (.F)
        set dir_verilog_files [file dirname [glob $manifest_file *.F]]
        foreach path $files {
            # Concatenate the directory of the manifest file (.F) with the file list (.v .sv) to have the abs path
            lappend abs_files $dir_verilog_files/$path
        }
        # Load the list of verilog files
        load_vsrc $obj $abs_files
        close $fp_verilog_files
    }
}

load_vsrc $obj $vsrc_files

load_vsrc_manifest $obj $vsrc_manifest
