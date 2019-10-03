
module ahb_to_ri5cy # (
  parameter AHB_ADDR_WIDTH = 32,
  parameter AHB_DATA_WIDTH = 32
)(
  input   clk,
  input   rstn,
  // Custom RI5CY memory interface
  output  logic req_o,
  output  logic we_o,
  output  logic [3:0] be_o,
  output  logic [31:0] addr_o,
  output  logic [31:0] wdata_o,
  input   [31:0] rdata_i,
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

  logic [2:0] fsm_st, next_st;
  logic [3:0] be, be_saved;

  assign addr_o       = haddr_i;
  assign we_o         = hwrite_i;
  assign wdata_o      = hwdata_i;
  assign hrdata_o     = rdata_i;
  assign hreadyout_o  = 1'b1;
  assign hresp_o      = 1'b0;
  assign be_o         = (req_o && ~hwrite_i) ? be : be_saved;

  always @ (posedge clk) begin
    if (rstn == 1'b0) begin
      be_saved <= 4'd0;
    end
    else begin
      be_saved <= be;
    end
  end

  always @ (*) begin
    case (hsize_i)
      WORD:     be = 4'b1111;
      HALFWORD: be = 4'b0011;
      BYTE:     be = 4'b0001;
      default:  be = 4'b0000;
    endcase
  end

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
endmodule
