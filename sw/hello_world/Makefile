PREFIX	?=	riscv-none-embed-
CC			:=	$(PREFIX)gcc
OBJDUMP	:=	$(PREFIX)objdump
OBJCOPY	:=	$(PREFIX)objcopy
GDB			:=	$(PREFIX)gdb
SIZE		:=	$(PREFIX)size

CFLAGS	:=	-march=rv32imc 			\
						-mabi=ilp32 				\
						-Wall 							\
						-Wno-unused 				\
						-ffreestanding			\
						-O0 -g							\
						--specs=nano.specs	\
						-Wall -Wno-main
						# -mstrict-align = Add this to avoid misaligned access
LDFLAGS	:=	-g 												\
						-Wl,-gc-sections 					\
						-Wl,-Map=output/image.map \
						-march=rv32imc 						\
						-mabi=ilp32 							\
						-nostartfiles 						\
						--specs=nano.specs 				\
						--specs=nosys.specs 			\
						-lm -lc -lgcc

TARGET_NAME	:= $(notdir $(shell pwd))
ODIR				:=	output
TEMP				:=	output_temp
TARGET			:=	$(ODIR)/$(TARGET_NAME)
LD_SCRIPT		:=	-Tsections.ld
INC					:=	common
INC_API			:=	API/inc
_OBJ    		:=	$(patsubst init/%,%.o,$(basename $(wildcard init/*.S)))
_OBJ    		+=	$(patsubst init/%,%.o,$(basename $(wildcard init/*.c)))
_OBJ    		+=	$(patsubst API/src/%,%.o,$(basename $(wildcard API/src/*.c)))
_OBJ    		+=	$(patsubst src/%,%.o,$(basename $(wildcard src/*.c)))
OBJ					:=	$(patsubst %,$(TEMP)/%,$(_OBJ))

$(shell   mkdir -p $(ODIR)_temp)
$(shell   mkdir -p $(ODIR))

.PHONY: all clean default

default: all

all: $(TARGET).asm
	@echo	"$(TARGET_NAME) builded"
	$(SIZE) -t $(TARGET).elf

$(ODIR)/prog_rom.v: $(TARGET).data
	@echo "Generating behavioral ROM in verilog with hex file"
	python scripts/gen_rom.py --in_hex $< --out_v $@

$(TARGET).data: $(TARGET).bin
	@echo "Generating hex format from elf to run in digital simulations..."
	python scripts/freedom-bin2hex.py --bit-width 32 $< $@

$(TARGET).asm:	$(TARGET).elf
	@echo "Generating disassembly of the code..."
	$(OBJDUMP) -t -D -h $< > $@

$(TARGET).bin:	$(TARGET).elf
	@echo "Generating binary format of the elf executable..."
	$(OBJCOPY) -O binary $< $@

$(TARGET).elf:	$(OBJ)
	@echo "Linking $@"
	$(CC) $(LD_SCRIPT) -I$(INC_API) -I$(INC) $(OBJ) -o $@ $(LDFLAGS)

$(TEMP)/%.o:	init/%.S
	@echo "Building $@"
	$(CC) $(CFLAGS) -save-temps=obj -I$(INC_API) -I$(INC) -c $< -o $@

$(TEMP)/%.o:	init/%.c
	@echo "Building $@"
	$(CC) $(CFLAGS) -save-temps=obj -I$(INC_API) -I$(INC) -c $< -o $@

$(TEMP)/%.o:  src/%.c
	@echo "Building $@"
	$(CC) $(CFLAGS) -save-temps=obj -I$(INC_API) -I$(INC) -c $< -o $@

$(TEMP)/%.o:  API/src/%.c
	@echo "Building $@"
	$(CC) $(CFLAGS) -save-temps=obj -I$(INC_API) -I$(INC) -c $< -o $@

debug:
	@echo "Use disass /m name_of_the_function to search for a function in assembly/c\n"
	$(GDB) $(TARGET).elf

clean:
	@echo "Cleaning all..."
	rm -rf $(ODIR)
	rm -rf $(TEMP)
