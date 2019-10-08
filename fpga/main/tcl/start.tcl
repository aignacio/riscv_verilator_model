set prj_name $::env(PROJECT_NAME)

set out_dir $::env(OUT_DIR)

set inc_dir $::env(INCL_DIR)

set macros_vlog $::env(MACROS_VLOG)

# For +incdir+
set include_directories {}
foreach var $inc_dir {
    puts "    -> Including dir $var"
    lappend include_directories $var
}

# For +define+
set defined_macros {}
foreach var $macros_vlog {
    puts "    -> Adding verilog macro $var"
    lappend defined_macros $var
}

while {[llength $argv]} {
  set argv [lassign $argv[set argv {}] flag]
  switch -glob $flag {
    -top-module {
      set argv [lassign $argv[set argv {}] top]
    }
    -F {
      set argv [lassign $argv[set argv {}] vsrc_manifest]
    }
    -synth_mode {
      set argv [lassign $argv[set argv {}] synth_mode]
    }
    -v {
      set argv [lassign $argv[set argv {}] vsrc_files]
    }
    -xil_board {
      set argv [lassign $argv[set argv {}] board]
    }
    -xil_part {
      set argv [lassign $argv[set argv {}] part]
    }
    default {
      return -code error [list {unknown option} $flag]
    }
  }
}

if {![info exists synth_mode]} {
  return -code error [list {--synth_mode option is required}]
}

if {![info exists top]} {
  return -code error [list {--top-module option is required}]
}

if {![info exists board]} {
  return -code error [list {--xil_board option is required}]
}

if {![info exists part]} {
  return -code error [list {--xil_part option is required}]
}

# set tcl_files [glob $constraints_dir/*.xdc]

# Creates a work directory
set wrkdir [file join [pwd] $out_dir]

# Creates a ip work directory
set ipdir [file join $wrkdir ip]

# Create an in-memory project
puts "Creating project with name: $prj_name"

create_project -part $part -force $wrkdir/$prj_name

# Set the board part, target language, default library, and IP directory
# paths for the current project
set_property -dict [list \
	BOARD_PART $board \
	TARGET_LANGUAGE {Verilog} \
	DEFAULT_LIB {xil_defaultlib} \
    IP_REPO_PATHS $ipdir \
	] [current_project]

puts "Creating fileset of sources..."

if {[get_filesets -quiet sources_1] eq ""} {
	create_fileset -srcset sources_1
}

set obj [current_fileset]

puts "Creating fileset of simulation..."

if {[get_filesets -quiet sim_1] eq ""} {
	create_fileset -simset sim_1
}

set obj [current_fileset -simset]

puts "Creating fileset of constraints..."

if {[get_filesets -quiet constrs_1] eq ""} {
	create_fileset -constrset constrs_1
}
