# Create an MCS-format memory configuration file from a bitstream and an
# optional data file.
while {[llength $argv]} {
  set argv [lassign $argv[set argv {}] flag]
  switch -glob $flag {
    -xil_board {
      set argv [lassign $argv[set argv {}] board]
    }
    -xil_part {
      set argv [lassign $argv[set argv {}] part_fpga]
    }
    -mcsfile {
      set argv [lassign $argv[set argv {}] mcsfile]
    }
    -bitfile {
      set argv [lassign $argv[set argv {}] bitfile]
    }
    -datafile {
      set argv [lassign $argv[set argv {}] datafile]
    }
    default {
      return -code error [list {unknown option} $flag]
    }
  }
}

namespace eval ::program::boards {}

set ::program::boards::spec [dict create \
	arty            [dict create  iface spix4   size 16   bitaddr 0x0        memdev {n25q128-3.3v-spi-x1_x2_x4}] \
	arty_a7_100     [dict create  iface spix4   size 16   bitaddr 0x0        memdev {s25fl128sxxxxxx0-spi-x1_x2_x4}] \
	vc707           [dict create  iface bpix16  size 128  bitaddr 0x3000000  ] \
	vcu118          [dict create  iface spix8   size 256  bitaddr 0x0        memdev {mt25qu01g-spi-x1_x2_x4_x8}]]

if {![dict exists $::program::boards::spec $board]} {
	puts {Unsupported board}
	exit 1
}

set board [dict get $::program::boards::spec $board]

write_cfgmem -format mcs -interface [dict get $board iface] -size [dict get $board size] \
	-loadbit "up [dict get $board bitaddr] $bitfile" \
	-loaddata [expr {$datafile ne "" ? "up 0x400000 $datafile" : ""}] \
	-file $mcsfile -force
