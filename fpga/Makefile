.EXPORT_ALL_VARIABLES:
################# PROJECT DEPENDENT SETTINGS #################
PROJECT				:=	$(PROJECT_NAME)_$(FPGA_BOARD)
PROJECT_NAME	:=	$(shell echo $(PROJECT) | tr A-Z a-z)

### Project files
PATH_FILES	:=	$(abspath ../)
# List all include folders
INCL_DIR		:=	$(addprefix $(PATH_FILES)/,$(INC_VERILOG))
# You can list below all files in the verilog/system verilog format
PRJ_FILES_V	:=	$(addprefix $(PATH_FILES)/,$(SRC_VERILOG)) \
								$(PATH_FILES)/tb/wrappers/fpga_wrapper/fpga_wrapper.sv
MACROS_VLOG	:=	$(MACRO_VLOG)

### You can list below all files in the manifest format (.F - List of all verilog files)
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
