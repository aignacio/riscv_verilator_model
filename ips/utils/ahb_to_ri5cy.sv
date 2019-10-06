
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

  localparam  IDLE       = 0,
              WAIT_REQ   = 1,
              NEW_REQ    = 2,
              WRITE_REQ = 3;

  logic [2:0] fsm_st, next_st;
  logic [3:0] be;
  logic [3:0] be_saved;
  logic [31:0] haddr_saved;
  logic [31:0] hrdata_saved;
  logic rdata_mem, lock;

  assign wr_req       = hsel_i && hwrite_i;
  assign rd_req       = hsel_i && ~hwrite_i;
  assign hrdata_o     = lock ? hrdata_saved : rdata_i;
  assign hreadyout_o  = (fsm_st == WRITE_REQ) ? 1'b0 : 1'b1;
  assign hresp_o      = 1'b0;

  always @ (*) begin
    case(fsm_st)
      WRITE_REQ: begin
        addr_o  = haddr_saved;
        we_o    = 1'b1;
        wdata_o = hwdata_i;
        be_o    = be_saved;
      end
      default: begin
        addr_o  = haddr_i;
        we_o    = hwrite_i;
        wdata_o = hwdata_i;
        be_o    = be;
      end
    endcase
  end

  always @ (posedge clk) begin
    if (rstn == 1'b0) begin
      be_saved      <= 4'd0;
      haddr_saved   <= 32'h0;
      hrdata_saved  <= 32'h0;
      rdata_mem     <= 1'b0;
      lock          <= 1'b0;
    end
    else begin
      if (hsel_i == 1'b1) begin
        be_saved      <= be;
        haddr_saved   <= haddr_i;
      end

      if (rd_req)
        rdata_mem <= 1'b1;
      else
        rdata_mem <= 1'b0;

      if (~hready_i && rdata_mem && ~lock) begin
        hrdata_saved <= rdata_i;
        lock <= 1'b1;
      end

      if (hready_i)
        lock <= 1'b0;
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
    if (rstn == 1'b0)
      fsm_st <= IDLE;
    else
      if (hready_i  ==  1'b0      &&
          fsm_st    !=  IDLE      &&
          fsm_st    !=  WRITE_REQ &&
          next_st   !=  WRITE_REQ)
        fsm_st <= fsm_st;       // Wait....
      else
        fsm_st <= next_st;      // In this case, go ahead
  end

  always @ (*) begin
    case(fsm_st)
      IDLE:
        if (wr_req)
          next_st = WRITE_REQ;
        else if (rd_req)
          next_st = WAIT_REQ;
        else
          next_st = IDLE;
      WAIT_REQ:
        if (wr_req)
          next_st = WRITE_REQ;
        else if (rd_req)
          next_st = NEW_REQ;
        else
          next_st = IDLE;
      NEW_REQ:
        if (wr_req)
          next_st = WRITE_REQ;
        else if (rd_req)
          next_st = WAIT_REQ;
        else
          next_st = IDLE;
      WRITE_REQ:
        next_st = IDLE;
      default: begin
        next_st = IDLE;
      end
    endcase
  end

  always @ (*) begin
    case(fsm_st)
      IDLE:
        if (wr_req)
          req_o = 1'b0;
        else if (rd_req)
          req_o = 1'b1;
        else
          req_o = 1'b0;
      WAIT_REQ:
        if (wr_req)
          req_o = 1'b0;
        else if (rd_req)
          req_o = 1'b1;
        else
          req_o = 1'b0;
      NEW_REQ:
        if (wr_req)
          req_o = 1'b0;
        else if (rd_req)
          req_o = 1'b1;
        else
          req_o = 1'b0;
      WRITE_REQ:
        req_o = 1'b1;
      default:  req_o = 1'b0;
    endcase
  end
endmodule
