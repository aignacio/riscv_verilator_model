interface ahb3lite_if #(
  parameter HADDR_SIZE = 32,
  parameter HDATA_SIZE = 32
);
  logic HSEL;
  logic [HADDR_SIZE -1:0] HADDR;
  logic [HDATA_SIZE -1:0] HWDATA;
  logic [HDATA_SIZE -1:0] HRDATA;
  logic HWRITE;
  logic [2:0] HSIZE;
  logic [2:0] HBURST;
  logic [3:0] HPROT;
  logic [1:0] HTRANS;
  logic HMASTLOCK;
  logic HREADY;
  logic HREADYOUT;
  logic HRESP;

endinterface
