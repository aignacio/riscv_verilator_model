while {[llength $argv]} {
  set argv [lassign $argv[set argv {}] flag]
  switch -glob $flag {
    -mcs {
      set argv [lassign $argv[set argv {}] mcs]
    }
    default {
      return -code error [list {unknown option} $flag]
    }
  }
}

set hw_part $::env(HW_PART)
set mem_part $::env(MEM_PART)

puts "Configuration file used: $mcs"
puts "Configuration hw part used: $hw_part"
puts "Configuration mem part used: $mem_part"
puts "Starting to connect with ARTIX A7 DIGILENT FPGA BOARD..."
open_hw
connect_hw_server
open_hw_target
current_hw_device [get_hw_devices $hw_part]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $hw_part] 0]

puts "Creating the configuration file memory..."
create_hw_cfgmem -hw_device [lindex [get_hw_devices $hw_part] 0] [lindex [get_cfgmem_parts $mem_part] 0]
set_property PROGRAM.BLANK_CHECK  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]
set_property PROGRAM.ERASE  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]
set_property PROGRAM.CFG_PROGRAM  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]
set_property PROGRAM.VERIFY  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]
set_property PROGRAM.CHECKSUM  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]
refresh_hw_device [lindex [get_hw_devices $hw_part] 0]

set_property PROGRAM.ADDRESS_RANGE  {use_file} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]
set_property PROGRAM.FILES $mcs [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]
set_property PROGRAM.PRM_FILE {} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]
set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]
set_property PROGRAM.BLANK_CHECK  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]
set_property PROGRAM.ERASE  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]
set_property PROGRAM.CFG_PROGRAM  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]
set_property PROGRAM.VERIFY  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]
set_property PROGRAM.CHECKSUM  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]

puts "Programming the SPI FLASH memory..."
startgroup
if {![string equal [get_property PROGRAM.HW_CFGMEM_TYPE  [lindex [get_hw_devices $hw_part] 0]] [get_property MEM_TYPE [get_property CFGMEM_PART [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]]]] }  { create_hw_bitstream -hw_device [lindex [get_hw_devices $hw_part] 0] [get_property PROGRAM.HW_CFGMEM_BITFILE [ lindex [get_hw_devices $hw_part] 0]]; program_hw_devices [lindex [get_hw_devices $hw_part] 0]; };
program_hw_cfgmem -hw_cfgmem [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $hw_part] 0]]
endgroup
