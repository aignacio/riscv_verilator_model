#! /usr/bin/env python3
# Copyright https://github.com/aignacio
import argparse
import sys
import math

def gen_rom(hex, rom_mem):
    address_width = math.ceil(math.log(sum(1 for line in hex),2));
    rom_mem.write("module boot_rom_generic (\n");
    rom_mem.write("  input   rst_n,\n");
    rom_mem.write("  input   clk,\n");
    rom_mem.write("  input   [%d:0] raddr_i,\n" % (address_width-1));
    rom_mem.write("  output  reg [31:0] dout_o\n");
    rom_mem.write(");\n\n");
    rom_mem.write("(*rom_style = \"block\" *) const logic [0:%d] [31:0] mem_array = {\n" % (2**(address_width)-1));
    hex.seek(0);
    hex_lines = hex.readlines()[:-1]
    hex.seek(0);
    last_line = hex.readlines()
    for line in hex_lines:
        rom_mem.write("    32\'h%s,\n" % line.rstrip());
    rom_mem.write("    32\'h%s\n" % last_line[-1].rstrip());
    rom_mem.write("  };\n\n");
    rom_mem.write("  always @(posedge clk)\n");
    rom_mem.write("    if (rst_n == 1\'b0)\n");
    rom_mem.write("      dout_o <= 32\'d0;\n");
    rom_mem.write("    else\n");
    rom_mem.write("      dout_o <= mem_array[raddr_i];\n");
    rom_mem.write("endmodule\n");

def gen_rom_xilinx(hex, rom_mem):
    address_width = math.ceil(math.log(sum(1 for line in hex),2))+1;
    rom_mem.write("// -----------------------------------------------------\n");
    rom_mem.write("// Please don't edit this code, its automatic generated!\n");
    rom_mem.write("// -> Check: gen_rom.py                                 \n");
    rom_mem.write("// -----------------------------------------------------\n");
    rom_mem.write("module boot_rom_generic (\n");
    rom_mem.write("  input   rst_n,\n");
    rom_mem.write("  input   clk,\n");
    rom_mem.write("  input   en,\n");
    rom_mem.write("  input   [%d:0] raddr_i,\n" % (address_width-1));
    rom_mem.write("  output  [31:0] dout_o\n");
    rom_mem.write(");\n\n");
    rom_mem.write("  (*rom_style = \"block\" *) reg [31:0] mem;\n\n");
    rom_mem.write("  assign dout_o = mem;\n");
    rom_mem.write("  always @(posedge clk)\n");
    rom_mem.write("     if(en)\n");
    rom_mem.write("         case(raddr_i)\n");
    hex.seek(0);
    hex_lines = hex.readlines()[:-1]
    hex.seek(0);
    last_line = hex.readlines();
    address_index = 0;
    for line in hex_lines:
        rom_mem.write("         %d\'d%06d: mem <= 32'h%s;\n" % (address_width,address_index*4,line.rstrip()));
        address_index += 1;
    rom_mem.write("         endcase\n\n");
    rom_mem.write("endmodule\n");

def main():
    parser = argparse.ArgumentParser(
        description='Convert a hexadecimal program file into behavioral rom memory.'
    )
    if sys.version_info >= (3, 0):
        parser.add_argument('--in_hex',
                            help="Input file in hex format compatible with $readmemh - 32bits/line",
                            nargs='?',
                            type=argparse.FileType('r'),
                            default=sys.stdin.buffer)
    else:
        parser.add_argument('--in_hex',
                            help="Input file in hex format compatible with $readmemh - 32bits/line",
                            nargs='?',
                            type=argparse.FileType('rb'),
                            default=sys.stdin)

    parser.add_argument('--out_v',
                        help="Output file with in verilog of the behavioral ROM memory ",
                        nargs='?',
                        type=argparse.FileType('w'),
                        default=sys.stdout)

    args = parser.parse_args()
    gen_rom_xilinx(args.in_hex, args.out_v)

if __name__ == '__main__':
    main()
