`include "config_soc.v"

module filter_oor (
  input   [31:0] addr_i,
  input   input_sel_i,
  output  valid_o,
  output  error_o
);
  logic enable_valid;

  assign valid_o = enable_valid ? '1 : '0;
  assign error_o = input_sel_i && ~enable_valid;

  always @ (*) begin
    $display(`AHB_SL_BASE_ADDR_0 + ~(`AHB_SL_MASK_ADDR_0));
    if (input_sel_i &&
        (addr_i >= `AHB_SL_BASE_ADDR_0 && addr_i <= (`AHB_SL_BASE_ADDR_0 + ~(`AHB_SL_MASK_ADDR_0))) ||
        (addr_i >= `AHB_SL_BASE_ADDR_1 && addr_i <= (`AHB_SL_BASE_ADDR_1 + ~(`AHB_SL_MASK_ADDR_1))) ||
        (addr_i >= `AHB_SL_BASE_ADDR_2 && addr_i <= (`AHB_SL_BASE_ADDR_2 + ~(`AHB_SL_MASK_ADDR_2))) ||
        (addr_i >= `AHB_SL_BASE_ADDR_3 && addr_i <= (`AHB_SL_BASE_ADDR_3 + ~(`AHB_SL_MASK_ADDR_3))) ||
        (addr_i >= `AHB_SL_BASE_ADDR_4 && addr_i <= (`AHB_SL_BASE_ADDR_4 + ~(`AHB_SL_MASK_ADDR_4))) ||
        (addr_i >= `AHB_SL_BASE_ADDR_5 && addr_i <= (`AHB_SL_BASE_ADDR_5 + ~(`AHB_SL_MASK_ADDR_5)))) begin
      enable_valid = 1;
    end
    else begin
      enable_valid = 0;
    end
  end
endmodule
