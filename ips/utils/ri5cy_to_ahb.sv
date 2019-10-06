
module ri5cy_to_ahb # (
  parameter AHB_ADDR_WIDTH = 32,
  parameter AHB_DATA_WIDTH = 32
)(
  input   clk,
  input   rstn,
  // Custom RI5CY memory interface
  input   req_i,
  input   we_i,
  input   [3:0] be_i,
  input   [31:0] addr_i,
  input   [31:0] wdata_i,
  output  gnt_o,
  output  rvalid_o,
  output  [31:0] rdata_o,
  // AHB master signals
  output  hsel_o,
  output  [AHB_ADDR_WIDTH-1:0] haddr_o,
	output  [AHB_DATA_WIDTH-1:0] hwdata_o,
	output  hwrite_o,
	output  [2:0] hsize_o,
	output  [2:0] hburst_o,
	output  [3:0] hprot_o,
	output  [1:0] htrans_o,
	output  hmastlock_o,
  output  hready_o,
  input   [AHB_DATA_WIDTH-1:0] hrdata_i,
	input   hreadyout_i,
	input   hresp_i
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

  logic rvalid, rvalid_en;
  logic [2:0] hsize;
  logic [31:0] haddr, hwdata_tmp, hwmask;
  logic error_on_transfer;
  logic [2:0] fsm_st, next_st;

  assign hprot_o = 4'b0011;   // If a master is not capable of generating accurate
                              // protection information, ARM Limited the master
                              // sets HPROT_o to b0011 to correspond to a non-cacheable,
                              // non-bufferable, privileged, data access recommends that:
  assign hmastlock_o = 1'b0;  // If the master requires locked accesses then it must also
                              // assert the HMASTLOCK_o signal. This signal indicates to any
                              // slave that the current transfer sequence is indivisible
                              // and must therefore be processed before any other transact
                              // ions are processed. After a locked transfer, it is recomm
                              // ended that the master inserts an IDLE transfer.
  assign htrans_o = (req_i) ? NONSEQ_HTRANS : IDLE_HTRANS; // We use just single non-sequential transfer or idle htrans
                                                            // Indicates that no data transfer is required. A master uses
                                                            // an IDLE transfer when it does not want to perform a data
                                                            // transfer.

  assign error_on_transfer = hresp_i;
  assign haddr = addr_i;
  assign gnt_o = hreadyout_i;
  assign hready_o = hreadyout_i;
  assign hburst_o = 3'b000; // Always single burst
  assign hwrite_o = we_i;
  assign hsize_o = hsize;
  assign haddr_o = haddr;
  assign hwdata_o = hwdata_tmp;
  assign hsel_o = req_i;
  assign rvalid_o = rvalid;
  assign rdata_o = hrdata_i;

  genvar i;
  for (i=0;i<4;i++) begin
    assign hwmask[i*8+:8] = {8{be_i[i]}} & wdata_i[i*8+:8];
  end

  always @ (*) begin
    if (be_i == 4'b1111 || be_i == 4'b1110) begin
      hsize = WORD;
    end
    else if (be_i == 4'b0011 || be_i == 4'b0110 || be_i == 4'b1100) begin
      hsize = HALFWORD;
    end
    else begin
      hsize = BYTE;
    end
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
        if (~hreadyout_i)
          next_st = IDLE;
        else if (req_i)
          next_st = WAIT_REQ;
        else
          next_st = IDLE;
      WAIT_REQ:
        if (~hreadyout_i)
          next_st = WAIT_REQ;
        else if (req_i)
          next_st = NEW_REQ;
        else
          next_st = IDLE;
      NEW_REQ: begin
        if (~hreadyout_i)
          next_st = NEW_REQ;
        else if (req_i)
          next_st = WAIT_REQ;
        else
          next_st = IDLE;
      end
      default: begin
        next_st = IDLE;
      end
    endcase
  end

  always @ (posedge clk) begin
    if (~rstn) begin
      hwdata_tmp <= 32'h0;
    end
    else begin
      if (req_i && hreadyout_i)
        hwdata_tmp <= hwmask;
    end
  end

  // always @ (posedge clk) begin
  //   if (~rstn) begin
  //     rvalid_en <= 1'b0;
  //   end
  //   else begin
  //     if (req_i == 1'b1 && we_i == 1'b0) begin
  //       rvalid_en <= 1'b1;
  //     end
  //     else if (req_i == 1'b1 && we_i == 1'b1) begin
  //       rvalid_en <= 1'b0;
  //     end
  //     else begin
  //       rvalid_en <= 1'b0;
  //     end
  //   end
  // end

  always @ (*) begin
    case(fsm_st)
      IDLE:
        rvalid = 1'b0;
      WAIT_REQ:
        if (hreadyout_i == 1'b0)
          rvalid = 1'b0;
        else
          rvalid = 1'b1;
      NEW_REQ:
        if (hreadyout_i == 1'b0)
          rvalid = 1'b0;
        else
          rvalid = 1'b1;
      default:
        rvalid = 1'b0;
    endcase
  end
endmodule
