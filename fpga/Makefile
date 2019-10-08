.EXPORT_ALL_VARIABLES:
################# PROJECT DEPENDENT SETTINGS #################
PROJECT				:=	riscv_fpga
XILINX_TARGET	:=	arty
XILINX_BOARD	:=	digilentinc.com:arty-a7-100:part0:1.0
XILINX_PART		:=	xc7a100tcsg324-1
CPU_CORES			?=	8
TOP_MODULE		:=	artix_wrapper
PROJECT_NAME	:=	$(shell echo $(PROJECT) | tr A-Z a-z)
SYNTH_MODE		:=	none
# Synthesis modes
# • rebuilt - This will attempt to rebuild the original hierarchy of the RTL design after synthesis
# has completed. This is the default setting.
# • full - Flatten the hierarchy of the design.
# • none - Do not flatten the hierarchy of the design. This will preserve the hierarchy of the
# design, but will also limit the design optimization that can be performed by the synthesis
# tool.

# Project files

# List all include folders
PATH_FILES	:=	$(abspath ../)

INCL_DIR		:=	$(addprefix $(PATH_FILES)/,$(INC_VERILOG))

# You can list below all files in the verilog/system verilog format
PRJ_FILES_V	:=	$(addprefix $(PATH_FILES)/,$(SRC_VERILOG)) \
								$(PATH_FILES)/tb/wrappers/fpga_wrapper/fpga_wrapper.sv

MACROS_VLOG	:=	$(MACRO_VLOG) \
								VERILATOR

# You can list below all files in the manifest format (.F - List of all verilog files)
PRJ_FILES_F	:=

################# INDEPENDENT SETTINGS #################
.PHONY: help
help:
	@echo "Targets available:"
	@echo "\tall - Build the project folder"
	@echo "\tmcs - [TARGET DEPENDENT] Generate the mcs file to program SPI flash"
	@echo "\tprogram_mcs - [TARGET DEPENDENT] Program the memory file into the SPI flash through Vivado"
	@echo "\tclean - Clean the project builded"
	@echo "\tforce - Force rebuild the project"

.PHONY:	clean force all mcs program_mcs

force: clean
	$(MAKE) -C main -f main.mk all

all:
	$(MAKE) -C main -f main.mk all

mcs:
	$(MAKE) -C main -f main.mk mcs

program_mcs:
	$(MAKE) -C main -f main.mk program_mcs

clean:
	$(MAKE) -C main -f main.mk clean
