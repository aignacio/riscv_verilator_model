OUT_DIR	:=	output
export OUT_DIR

.PHONY:	all
all:
ifneq ($(wildcard ./$(OUT_DIR)/),)
	@echo "Project has already been build, nothing to do!";
else
	@mkdir $(OUT_DIR)
	@echo "Start building the $(PROJECT)...."
	# After tclargs, we add all the custom options by tcl arguments
	vivado	-mode batch	\
		-notrace \
		-nojournal	\
		-source	tcl/run.tcl	\
		-log	$(OUT_DIR)/console.log	\
		-tclargs	\
		-top-module	"$(TOP_MODULE)" \
		-xil_board	"$(XILINX_BOARD)" \
		-xil_part	"$(XILINX_PART)" \
		-v "$(PRJ_FILES_V)" \
		-F "$(PRJ_FILES_F)" \
		-synth_mode "$(SYNTH_MODE)"
endif

.PHONY:	mcs
mcs:
	vivado -mode batch \
		-notrace \
		-nojournal \
		-source tcl/write_cfgmem.tcl \
		-log	$(OUT_DIR)/console_mcs_gen.log	\
		-tclargs	\
		-xil_board	"$(XILINX_TARGET)" \
		-xil_part	"$(XILINX_PART)" \
		-mcsfile	"$(OUT_DIR)/$(PROJECT_NAME).mcs" \
		-bitfile	"$(OUT_DIR)/$(PROJECT_NAME).bit"\
		-datafile	""

.PHONY:	program_mcs
program_mcs:
	vivado -mode batch \
		-notrace \
		-nojournal \
		-source tcl/program_mcs.tcl	\
		-tclargs	\
		-mcs	"$(OUT_DIR)/$(PROJECT_NAME).mcs"

.PHONY:	clean
clean:
ifneq ($(wildcard ./$(OUT_DIR)/),)
	@echo -n "Cleaning $(PROJECT)..."
	@rm -rf $(OUT_DIR)
	@rm -rf vivado*
	@rm -rf .Xil*
else
	@echo "Nothing to clean at $(PROJECT)..."
endif

