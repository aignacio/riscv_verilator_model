module ahb_dummy #(
  parameter HADDR_SIZE        = 32,
  parameter HDATA_SIZE        = 32
)
(
  input                       HRESETn,
  input                       HCLK,
  input                       HSEL,
  input      [HADDR_SIZE-1:0] HADDR,
  input      [HDATA_SIZE-1:0] HWDATA,
  output     [HDATA_SIZE-1:0] HRDATA,
  input                       HWRITE,
  input      [           2:0] HSIZE,
  input      [           2:0] HBURST,
  input      [           3:0] HPROT,
  input      [           1:0] HTRANS,
  output                      HREADYOUT,
  input                       HREADY,
  output                      HRESP
);
  assign HRESP = 1'b0;
  assign HREADYOUT = 1'b1;
  assign HRDATA = 32'd0;
endmodule
