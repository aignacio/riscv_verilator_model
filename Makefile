# SHELL := /bin/bash
RISCV_TOOLCHAIN ?=	riscv-none-embed
export RISCV_TOOLCHAIN

##### Project variables
PROJECT_NAME	:=	riscv
VERILATOR_TB	:=	tb
IPS_FOLDER		:=	ips
# Define here the size of the RAMs once it need to check if the program fits
IRAM_KB_SIZE	:=	32
DRAM_KB_SIZE	:=	32
JTAG_BOOT			?=	0
JTAG_PORT			?=	8080
MAX_THREAD		?=	$(shell nproc --all)
##### FPGA makefile variables
FPGA_BOARD		:=	pynq
CPU_CORES			:=	8
FPGA_WRAPPER	:=	artix_wrapper
SYNTH_MODE		:=	none

ifeq ($(FPGA_BOARD),artix_a35)
	XILINX_BOARD	:=	digilentinc.com:arty-a7-35:part0:1.0
	XILINX_PART		:=	xc7a35ticsg324-1L
	XILINX_TARGET	:=	arty
	HW_PART				:=	xc7a35t_0
	MEM_PART			:=	mt25ql128-spi-x1_x2_x4
else ifeq ($(FPGA_BOARD),artix_a100)
	XILINX_BOARD	:=	digilentinc.com:arty-a7-100:part0:1.0
	XILINX_PART		:=	xc7a100tcsg324-1
	XILINX_TARGET	:=	arty
	HW_PART				:=	xc7a100t_0
	MEM_PART			:=	s25fl128sxxxxxx0-spi-x1_x2_x4
else ifeq ($(FPGA_BOARD),pynq)
	XILINX_BOARD	:=	www.digilentinc.com:pynq-z1:part0:1.0
	XILINX_PART		:=	xc7z020clg400-1
	XILINX_TARGET	:=	arty
	HW_PART				:=	xc7a100t_0
	MEM_PART			:=	mt25ql128-spi-x1_x2_x4
	#xilinx.com:zc702:1.0
else
	XILINX_BOARD	:=	digilentinc.com:arty-a7-35:part0:1.0
	XILINX_PART		:=	xc7a35ticsg324-1L
	XILINX_TARGET	:=	arty
	HW_PART				:=	xc7a35t_0
	MEM_PART			:=	mt25ql128-spi-x1_x2_x4
endif

# Synthesis modes
# • rebuilt - This will attempt to rebuild the original hierarchy of the RTL design after synthesis
# has completed. This is the default setting.
# • full - Flatten the hierarchy of the design.
# • none - Do not flatten the hierarchy of the design. This will preserve the hierarchy of the
# design, but will also limit the design optimization that can be performed by the synthesis
# tool.

##### Verilator Specific Simulation variables
OUT_VERILATOR	:=	output_verilator
TEST_PROG			:=	hello_world
TB_VERILATOR	:=	$(VERILATOR_TB)/cpp/testbench.cpp

DEPEND	   		:=	git				\
									gtkwave 	\
									verilator

# All the ips that are needed to build
SOC_IPS				:=	ahb3lite_pkg							\
									ahb3lite_memory						\
									ahb3lite_interconnect/rtl	\
									ahb3lite_apb_bridge				\
									apb_gpio 									\
									memory 										\
									apb4_mux 									\
									utils

# RI5CY RTLs files
COMMON_CELLS	:=	ips/common_cells/include/common_cells/registers.svh	\
									ips/common_cells/src/cdc_2phase.sv									\
									ips/common_cells/src/deprecated/fifo_v2.sv					\
									ips/common_cells/src/fifo_v3.sv											\
									ips/common_cells/src/rstgen.sv											\
									ips/common_cells/src/rstgen_bypass.sv

SRC_FPNEW			:=	ips/fpnew/src/fpnew_pkg.sv 																		\
									ips/fpnew/src/fpu_div_sqrt_mvp/hdl/defs_div_sqrt_mvp.sv 			\
									ips/fpnew/src/fpu_div_sqrt_mvp/hdl/preprocess_mvp.sv 					\
									ips/fpnew/src/fpu_div_sqrt_mvp/hdl/nrbd_nrsc_mvp.sv 					\
									ips/fpnew/src/fpu_div_sqrt_mvp/hdl/norm_div_sqrt_mvp.sv				\
									ips/fpnew/src/fpu_div_sqrt_mvp/hdl/control_mvp.sv							\
									ips/fpnew/src/fpu_div_sqrt_mvp/hdl/iteration_div_sqrt_mvp.sv	\
									ips/fpnew/src/fpu_div_sqrt_mvp/hdl/div_sqrt_top_mvp.sv 				\
									ips/fpnew/src/fpnew_cast_multi.sv 														\
									ips/fpnew/src/fpnew_top.sv 																		\
									ips/fpnew/src/fpnew_opgroup_fmt_slice.sv 											\
									ips/fpnew/src/fpnew_rounding.sv 															\
									ips/fpnew/src/fpnew_noncomp.sv 																\
									ips/fpnew/src/fpnew_opgroup_block.sv													\
									ips/fpnew/src/fpnew_fma_multi.sv 															\
									ips/fpnew/src/fpnew_fma.sv																		\
									ips/fpnew/src/fpnew_classifier.sv 														\
									ips/fpnew/src/fpnew_divsqrt_multi.sv													\
									ips/fpnew/src/fpnew_opgroup_multifmt_slice.sv 								\
									ips/fpnew/src/common_cells/src/lzc.sv 												\
									ips/fpnew/src/common_cells/src/rr_arb_tree.sv

SRC_RI5CY			:=	ips/riscv/tb/dm/riscv_tb_pkg.sv								\
									ips/riscv/tb/dm/boot_rom.sv										\
									ips/riscv/tb/core/cluster_clock_gating.sv			\
									ips/riscv/rtl/include/apu_core_package.sv     \
									ips/riscv/rtl/include/riscv_defines.sv        \
									ips/riscv/rtl/register_file_test_wrap.sv      \
									ips/riscv/rtl/riscv_alu.sv                    \
									ips/riscv/rtl/riscv_alu_basic.sv              \
									ips/riscv/rtl/riscv_alu_div.sv                \
									ips/riscv/rtl/riscv_compressed_decoder.sv     \
									ips/riscv/rtl/riscv_controller.sv             \
									ips/riscv/rtl/riscv_cs_registers.sv           \
									ips/riscv/rtl/riscv_fetch_fifo.sv							\
									ips/riscv/rtl/riscv_decoder.sv                \
									ips/riscv/rtl/riscv_int_controller.sv         \
									ips/riscv/rtl/riscv_ex_stage.sv               \
									ips/riscv/rtl/riscv_hwloop_controller.sv      \
									ips/riscv/rtl/riscv_hwloop_regs.sv            \
									ips/riscv/rtl/riscv_id_stage.sv               \
									ips/riscv/rtl/riscv_if_stage.sv               \
									ips/riscv/rtl/riscv_load_store_unit.sv        \
									ips/riscv/rtl/riscv_mult.sv                   \
									ips/riscv/rtl/riscv_prefetch_buffer.sv        \
									ips/riscv/rtl/riscv_prefetch_L0_buffer.sv     \
									ips/riscv/rtl/riscv_register_file.sv          \
									ips/riscv/rtl/riscv_core.sv                   \
									ips/riscv/rtl/riscv_apu_disp.sv               \
									ips/riscv/rtl/riscv_L0_buffer.sv              \
									ips/riscv/rtl/riscv_pmp.sv

SRC_RI5CY_DBG	:= 	ips/riscv-dbg/src/dm_pkg.sv										\
									ips/riscv-dbg/src/dmi_jtag.sv									\
									ips/riscv-dbg/src/dm_csrs.sv									\
									ips/riscv-dbg/src/dmi_jtag_tap.sv							\
									ips/riscv-dbg/src/dmi_cdc.sv									\
									ips/riscv-dbg/src/dm_top.sv										\
									ips/riscv-dbg/src/dm_sba.sv										\
									ips/riscv-dbg/src/dm_mem.sv										\
									ips/riscv-dbg/debug_rom/debug_rom.sv


# All sources needed to build the verilator model and FPGA
SRC_VERILOG 	:=	$(foreach IP,$(SOC_IPS),$(shell find $(IPS_FOLDER)/$(IP) -name *.v))
SRC_VERILOG 	+=	$(foreach IP,$(SOC_IPS),$(shell find $(IPS_FOLDER)/$(IP) -name *.sv))
SRC_VERILOG		+=	$(SRC_RI5CY_DBG)
SRC_VERILOG		+=	$(wildcard $(VERILATOR_TB)/wrappers/*.sv)
SRC_VERILOG		+=	$(wildcard $(VERILATOR_TB)/wrappers/*.v)
SRC_VERILOG		+=	$(COMMON_CELLS)
SRC_VERILOG		+=	$(SRC_FPNEW)
SRC_VERILOG		+=	$(SRC_RI5CY)
INC_VERILOG		:=	$(VERILATOR_TB)/inc								\
									$(IPS_FOLDER)/riscv/rtl/include		\
									$(IPS_FOLDER)/common_cells/include
INCS_VERILOG	:=	$(addprefix +incdir+,$(INC_VERILOG))
MACRO_VLOG		:=	IRAM_KB_SIZE=$(IRAM_KB_SIZE)			\
									DRAM_KB_SIZE=$(DRAM_KB_SIZE)			\
									JTAG_BOOT=$(JTAG_BOOT)
MACROS_VLOG		:=	$(addprefix +define+,$(MACRO_VLOG))
MACROS_VLOG		+=	$(addprefix +define+,SIMULATION)	# Added later cause MACRO_VLOG it's used by
																										# vivado, so SIMULATION should not be included

##### Verilator configuration stuff
ROOT_MOD_VERI	:=	$(PROJECT_NAME)_soc
VERILATOR_EXE	:=	$(OUT_VERILATOR)/$(ROOT_MOD_VERI)
SRC_CPP				:=	$(wildcard $(VERILATOR_TB)/cpp/*.cpp)
INC_CPP				:=	../tb/cpp/elfio
INCS_CPP			:=	$(addprefix -I,$(INC_CPP))
WAVEFORM_VCD	:=	/tmp/$(ROOT_MOD_VERI).vcd #$(OUT_VERILATOR)/$(ROOT_MOD_VERI).vcd
WAVEFORM_VERI	:=	$(VERILATOR_TB)/waveform_template/gtkwave_tmpl.gtkw
VERIL_FLAGS		:=	-O3 										\
									-Wno-CASEINCOMPLETE 		\
									-Wno-WIDTH							\
									-Wno-COMBDLY						\
									-Wno-UNOPTFLAT					\
									-Wno-LITENDIAN					\
									-Wno-UNSIGNED						\
									-Wno-IMPLICIT						\
									-Wno-CASEWITHX					\
									-Wno-CASEX							\
									-Wno-BLKANDNBLK					\
									-Wno-CMPCONST						\
									--exe										\
									--threads	$(MAX_THREAD)	\
									--trace 								\
									--trace-depth			1000	\
									--trace-max-array	1000	\
									--trace-max-width 1000	\
									--cc
CPPFLAGS_VERI	:=	"$(INCS_CPP) -O3 -g3 -Wall 						\
									-Werror -Wno-aligned-new 							\
									-DWAVEFORM_VCD=\"$(WAVEFORM_VCD)\" 		\
									-DIRAM_KB_SIZE=\"$(IRAM_KB_SIZE)\"		\
									-DDRAM_KB_SIZE=\"$(DRAM_KB_SIZE)\"		\
									-DJTAG_BOOT=\"$(JTAG_BOOT)\"					\
									-DJTAG_PORT=\"$(JTAG_PORT)\""
# WARN: rtls order matters in verilator compilation seq.
VERIL_ARGS		:=	-CFLAGS $(CPPFLAGS_VERI) 			\
									--top-module $(ROOT_MOD_VERI) \
									--Mdir $(OUT_VERILATOR)				\
									$(VERIL_FLAGS)								\
									$(INCS_CPP)										\
									$(INCS_VERILOG) 							\
									$(MACROS_VLOG)							 	\
									$(SRC_VERILOG) 								\
									$(SRC_CPP) 										\
									-o 														\
									$(ROOT_MOD_VERI)

export SRC_VERILOG
export INC_VERILOG
export MACRO_VLOG
export PROJECT_NAME
export XILINX_BOARD
export XILINX_PART
export XILINX_TARGET
export CPU_CORES
export FPGA_WRAPPER
export SYNTH_MODE
export FPGA_BOARD
export HW_PART
export MEM_PART
########################################################################
###################### DO NOT EDIT ANYTHING BELOW ######################
########################################################################
.PHONY: all clean check install \
				verilator clean sw run

help:
	@echo "Rules list:"
	@echo "all		- run verilator_sim"
	@echo "wave		- open gtkwave with waveform vcd dump"
	@echo "fpga		- synthetize riscv_soc throught vivado for fpga targets"
	@echo "clean		- clean verilator output builds"
	@echo "check		- check dependencies for running the project"
	@echo "install		- install dependencies through apt-get"
	@echo "verilator	- compile/run a complete SoC through verilator in C++"

all: verilator

####################### FPGA synthesis rules #######################
.PHONY: openocd_fpga program_mcs mcs fpga
fpga:
	+@make -C fpga force

mcs:
	+@make -C fpga $@

program_mcs:
	+@make -C fpga $@

openocd_fpga:
	riscv-openocd -f tb/debug/bus-pirate.cfg -f tb/debug/riscv_pulp_fpga.cfg

####################### verilator simulation rules #######################
wave:
	gtkwave -go $(WAVEFORM_VCD) $(WAVEFORM_VERI)

run: sw $(VERILATOR_EXE)
	$(VERILATOR_EXE) sw/$(TEST_PROG)/output/$(TEST_PROG).elf

verilator: $(VERILATOR_EXE)
	@echo "\n"
	@echo "Emulator build, for usage please follow:"
	@echo "\033[96m\e[1m./$(VERILATOR_EXE) -h\033[0m"
	@echo "\n"

$(VERILATOR_EXE): $(OUT_VERILATOR)/V$(ROOT_MOD_VERI).mk
	+@make -C $(OUT_VERILATOR) -f V$(ROOT_MOD_VERI).mk

$(OUT_VERILATOR)/V$(ROOT_MOD_VERI).mk: $(SRC_VERILOG) $(SRC_CPP) $(TB_VERILATOR)
	verilator $(VERIL_ARGS)

sw:
	+@make -C sw/$(TEST_PROG) all

openocd:
	riscv-openocd -f tb/debug/riscv_pulp.cfg

gdb:
	$(RISCV_TOOLCHAIN)-gdb sw/$(TEST_PROG)/output/$(TEST_PROG).elf -ex "target remote : 3333" -ex "load"

clean:
	$(info Cleaning verilator simulation files...)
	$(info rm -rf $(OUT_VERILATOR))
	@rm -rf $(OUT_VERILATOR)
	+@make -C sw/$(TEST_PROG) clean
	+@make -C fpga clean

####################### check for dependencies #######################
setup: check
	$(call print_logo)

check:
	$(foreach program,$(DEPEND),$(call check_program,$(program)))

install:
	$(foreach program,$(DEPEND),$(call install_program,$(program)))

####################### functions #######################
define check_program
	$(info Checking program [$(1)]...)
	$(if $(shell which $(1)),,$(error The program $(1) it's not installed!))
endef

define install_program
	$(info Installing [$(1)]...)
	sudo apt-get install -fy $(1)
endef
