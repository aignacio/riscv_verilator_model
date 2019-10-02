module ahb_dm_ri5cy #(
  parameter HADDR_SIZE = 32,
  parameter HDATA_SIZE = 32
)(
  input       HRESETn,
  input       HCLK,
  input       HSEL,
  input       [HADDR_SIZE-1:0] HADDR,
  input       [HDATA_SIZE-1:0] HWDATA,
  output      [HDATA_SIZE-1:0] HRDATA,
  input       HWRITE,
  input       [2:0] HSIZE,
  input       [2:0] HBURST,
  input       [3:0] HPROT,
  input       [1:0] HTRANS,
  output      HREADYOUT,
  input       HREADY,
  output      HRESP,
  output      dm_req_o,
  output      [31:0] dm_addr_o,
  output      dm_we_o,
  output      [3:0] dm_be_o,
  output      [31:0] dm_wdata_o,
  input       [31:0] dm_rdata_i,
  input       dm_rvalid_i,
  input       dm_gnt_i,
);
  // signals to read access debug unit
  // logic                          dm_req;
  // logic [31:0]                   dm_addr;
  // logic                          dm_we;
  // logic [3:0]                    dm_be;
  // logic [31:0]                   dm_wdata;
  // logic [31:0]                   dm_rdata;
  // logic                          dm_rvalid;
  // logic                          dm_gnt;

  // assign dm_req_o    = dm_req;
  // assign dm_addr_o   = dm_addr;
  // assign dm_we_o     = dm_we;
  // assign dm_be_o     = dm_be;
  // assign dm_wdata_o  = dm_wdata;
  // assign dm_rdata    = dm_rdata_i;
  // assign dm_rvalid   = dm_rvalid_i; // TODO: we dont' care about this
  // assign dm_gnt      = dm_gnt_i; // TODO: we don't care about this

  // always_comb begin
  //   dm_req    = HSEL;
  //   dm_addr   = HADDR;
  //   dm_we     = HWRITE;
  //   dm_be     = ;
  //   dm_wdata  = HWDATA;
  // end
endmodule
