
module ahb_ri5cy_rom # (
  parameter AHB_ADDR_WIDTH = 32,
  parameter AHB_DATA_WIDTH = 32,
  parameter JTAG_BOOT      = 0
)(
  input   clk,
  input   rstn,
  // AHB slave signals
  input   hsel_i,
  input   [AHB_ADDR_WIDTH-1:0] haddr_i,
	input   [AHB_DATA_WIDTH-1:0] hwdata_i,
	input   hwrite_i,
	input   [2:0] hsize_i,
	input   [2:0] hburst_i,
	input   [3:0] hprot_i,
	input   [1:0] htrans_i,
	input   hmastlock_i,
  input   hready_i,
  output  [AHB_DATA_WIDTH-1:0] hrdata_o,
	output  hreadyout_o,
	output  hresp_o
);
  localparam  IDLE_HTRANS   = 2'b00,
              BUSY_HTRANS   = 2'b01,
              NONSEQ_HTRANS = 2'b10,
              SEQ_HTRANS    = 2'b11;

  localparam  BYTE      = 3'b000,
              HALFWORD  = 3'b001,
              WORD      = 3'b010;

  localparam  IDLE      = 0,
              WAIT_REQ  = 1,
              NEW_REQ   = 2;

  logic req_o;
  logic [2:0] fsm_st, next_st;
  logic [31:0] rdata;

  assign hrdata_o     = rdata; // Keep looping while(1)
  assign hreadyout_o  = 1'b1;
  assign hresp_o      = 1'b0;

  always @ (posedge clk) begin
    if (~rstn)
      fsm_st <= IDLE;
    else
      fsm_st <= next_st;
  end

  always @ (*) begin
    case(fsm_st)
      IDLE:
        if (~hready_i)
          next_st = IDLE;
        else if (hsel_i)
          next_st = WAIT_REQ;
        else
          next_st = IDLE;
      WAIT_REQ:
        if (~hready_i)
          next_st = WAIT_REQ;
        else if (hsel_i)
          next_st = NEW_REQ;
        else
          next_st = IDLE;
      NEW_REQ: begin
        if (~hready_i)
          next_st = NEW_REQ;
        else if (hsel_i)
          next_st = WAIT_REQ;
        else
          next_st = IDLE;
      end
      default: begin
        next_st = IDLE;
      end
    endcase
  end

  always @ (*) begin
    case(fsm_st)
    IDLE:
      if (hready_i)
        if (hsel_i && ~hwrite_i)
          req_o = 1'b1;
        else
          req_o = 1'b0;
      else
        req_o = 1'b0;
    WAIT_REQ: req_o = 1'b1;
    NEW_REQ:  req_o = 1'b1;
    default:  req_o = 1'b0;
    endcase
  end

  // boot_rom rom (
  //   .clk_i(clk),
  //   .req_i(req_o),
  //   .addr_i(haddr_i[15:0]-'h80),
  //   .rdata_o(rdata)
  // );

  boot_rom_generic rom (
    .rst_n(rstn),
    .clk(clk),
    .en(req_o),
    .raddr_i(haddr_i[15:0]),
    .dout_o(rdata)
  );
endmodule
