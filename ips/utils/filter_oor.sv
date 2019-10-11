`include "config_soc.v"

module filter_oor (
  input   [31:0] addr_i,
  input   input_sel_i,
  output  valid_o,
  output  error_o
);
  logic enable_valid;
  logic [`AHB_SLAVES_NUM-1:0] en_addr;

  assign valid_o = enable_valid ? input_sel_i : '0;
  assign error_o = input_sel_i && ~enable_valid;

  genvar i;
  generate
    for (i=0; i < `AHB_SLAVES_NUM; i++) begin
      assign en_addr[i] = (addr_i >= ahb_addr[0][i] && addr_i <= ahb_addr[1][i]) ? 1'b1 : 1'b0;
    end
  endgenerate

  always @ (*) begin
    if (input_sel_i && |en_addr) begin
      enable_valid = 1;
    end
    else begin
      enable_valid = 0;
    end
  end
endmodule

