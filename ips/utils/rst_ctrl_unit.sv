module rst_ctrl_unit # (
  parameter PADDR_SIZE = 32,
  parameter PDATA_SIZE = 32,
  parameter DEFAULT_BOOT_ADDR = 32'h1A00_0000
)(
  input   PCLK,
  input   RESETn,
  // AHB slave signals
  input   PSEL,
  input   PENABLE,
  input   [PADDR_SIZE-1:0] PADDR,
	input   [PDATA_SIZE-1:0] PWDATA,
	input   PWRITE,
  output  [PDATA_SIZE-1:0] PRDATA,
	output  PREADY,
	output  PSLVERR,
  output  [31:0] rst_addr_o
);
  localparam  IDLE      = 0,
              WAIT_REQ  = 1,
              NEW_REQ   = 2;

  logic req;
  logic [2:0] fsm_st, next_st;
  logic [31:0] rst_addr;
  logic want_write;

  assign rst_addr_o   = rst_addr;
  assign PRDATA       = rst_addr;
  assign PREADY       = 1'b1;
  assign PSLVERR      = 1'b0;

  always @ (posedge PCLK) begin
    if (~RESETn)
      fsm_st <= IDLE;
    else
      fsm_st <= next_st;
  end

  always @ (*) begin
    case(fsm_st)
      IDLE:
        if (PSEL)
          next_st = WAIT_REQ;
        else
          next_st = IDLE;
      WAIT_REQ:
        if (PSEL)
          next_st = NEW_REQ;
        else
          next_st = IDLE;
      NEW_REQ: begin
        if (PSEL)
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
      if (PSEL && ~PWRITE)
        req = 1'b1;
      else
        req = 1'b0;
    WAIT_REQ: req = 1'b1;
    NEW_REQ:  req = 1'b1;
    default:  req = 1'b0;
    endcase
  end

  always @ (posedge PCLK) begin
    if (~RESETn) begin
      rst_addr <= DEFAULT_BOOT_ADDR;
      want_write <= 1'b0;
    end
    else begin
      if (PSEL && PWRITE)
        want_write <= 1'b1;
      else if (PSEL && ~PWRITE)
        want_write <= 1'b0;

      if (req && want_write) begin
        rst_addr <= PWDATA;
      end
    end
  end
endmodule
