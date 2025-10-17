 module FIFO#(parameter DSIZE = 8,
               parameter ASIZE = 4)
  (output logic [DSIZE-1:0] rdata,
   output logic       wfull, almost_full,
   output logic       rempty, almost_empty,
   input  logic [DSIZE-1:0] wdata,
   input  logic      winc, wclk, wrst_n,
   input  logic      rinc, rclk, rrst_n);
  logic   [ASIZE-1:0] waddr, raddr;
  logic  [ASIZE:0]   wptr, rptr, wq2_rptr, rq2_wptr;
  WSYNC      sync_r2w  (.wq2_rptr(wq2_rptr), .rptr(rptr),
                           .wclk(wclk), .wrst_n(wrst_n));
  RSYNC      sync_w2r  (.rq2_wptr(rq2_wptr), .wptr(wptr),
                           .rclk(rclk), .rrst_n(rrst_n));
  FIFO_MEM #(DSIZE, ASIZE) fifomem
                          (.rdata(rdata), .wdata(wdata),
                           .waddr(waddr), .raddr(raddr),
                           .wclken(winc), .wfull(wfull),
                           .wclk(wclk));
  EMPTY #(ASIZE)          rptr_empty
                          (.rempty(rempty),
			   .almost_empty(almost_empty),
                           .raddr(raddr),
                           .rptr(rptr), .rq2_wptr(rq2_wptr),
                           .rinc(rinc), .rclk(rclk),
                           .rrst_n(rrst_n));
  FULL #(ASIZE)     wptr_full
                          (.wfull(wfull), .almost_full(almost_full), 
			   .waddr(waddr),
                           .wptr(wptr), .wq2_rptr(wq2_rptr),
                           .winc(winc), .wclk(wclk),
                           .wrst_n(wrst_n));
 endmodule

///////////////////
//synchronizations
///////////////////
//synchronize write pointer
module RSYNC #(parameter ADDRSIZE = 4)
  (output logic [ADDRSIZE:0] rq2_wptr,
   input  logic [ADDRSIZE:0] wptr,
   input  logic rclk, rrst_n);
  logic [ADDRSIZE:0] rq1_wptr;
  always_ff @(posedge rclk or negedge rrst_n)
    if (!rrst_n) {rq2_wptr,rq1_wptr} <= 0;
    else         {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};
endmodule
//synchronize read pointer
module WSYNC #(parameter ADDRSIZE = 4)
  (output logic [ADDRSIZE:0] wq2_rptr,
   input  logic [ADDRSIZE:0] rptr,
   input  logic            wclk, wrst_n);
  logic [ADDRSIZE:0] wq1_rptr;
  always_ff @(posedge wclk or negedge wrst_n)
    if (!wrst_n) {wq2_rptr,wq1_rptr} <= 0;
    else         {wq2_rptr,wq1_rptr} <= {wq1_rptr,rptr};
 endmodule
///////////////
//FIFO memory
///////////////
 module FIFO_MEM #(
		 parameter  DATASIZE = 8,
                 parameter  ADDRSIZE = 4) // Number of mem address bits
  (output [DATASIZE-1:0] rdata,
   input  [DATASIZE-1:0] wdata,
   input  [ADDRSIZE-1:0] waddr, raddr,
   input                 wclken, wfull, wclk);
  
    localparam DEPTH = 1<<ADDRSIZE;
    logic [DATASIZE-1:0] mem [0:DEPTH-1];
    assign rdata = mem[raddr];
    always_ff @(posedge wclk)
      if (wclken && !wfull) mem[waddr] <= wdata;
 endmodule
///////////////
//EMPTY logic
///////////////
  module EMPTY #(parameter ADDRSIZE = 4)
  (output logic              rempty,
   output logic	             almost_empty,
   output logic[ADDRSIZE-1:0] raddr,
   output logic[ADDRSIZE  :0] rptr,
   input  logic[ADDRSIZE  :0] rq2_wptr,
   input  logic       rinc, rclk, rrst_n);
  logic  [ADDRSIZE:0] rbin;
  logic  [ADDRSIZE:0] b_wptr;
  logic  almost_empty_val;
  logic [ADDRSIZE:0] rgraynext, rbinnext;
  localparam DEPTH = 1<<ADDRSIZE;
  localparam factor=4;
  localparam GAP = DEPTH/factor;
  //------------------
  // both binary and gray style pointers are stored
  //------------------
  always_ff @(posedge rclk or negedge rrst_n)
    if (!rrst_n) {rbin, rptr} <= 0;
    else         {rbin, rptr} <= {rbinnext, rgraynext};
  // b_wptr is the transformed write pointer (binary) to compute the GAP between the read and write pointers
  always_comb begin
    b_wptr[ADDRSIZE]=rq2_wptr[ADDRSIZE];
    for (int i=ADDRSIZE-1;i>=0;i--)begin
	b_wptr[i]=b_wptr[i+1]^rq2_wptr[i];
    end    
    rbinnext  = rbin + (rinc & ~rempty);
    if (b_wptr-rbinnext<=GAP)begin
	almost_empty_val = 1'b1;
    end
    else begin
	almost_empty_val = 1'b0;
    end
  end
  assign raddr     = rbin[ADDRSIZE-1:0];
  assign rgraynext = (rbinnext>>1) ^ rbinnext;
  //--------------------------------------------------------------
  // FIFO empty when the next rptr == synchronized wptr or on reset
  //--------------------------------------------------------------
  assign rempty_val = (rgraynext == rq2_wptr);
  always_ff @(posedge rclk or negedge rrst_n)
    if (!rrst_n) begin
       rempty <= 1'b1;
       almost_empty <= '0;
    end
    else  begin
       rempty <= rempty_val;
       almost_empty <= almost_empty_val;
       //$display("rbinnext:%d, b_wptr:%d, GAP:%d, almost_full:%b ",rbinnext, b_wptr, GAP, almost_empty_val);
    end
 endmodule

//////////////
//FULL logic 
//////////////
 module FULL  #(parameter ADDRSIZE = 4)
  (output logic wfull,
   output logic almost_full,
   output logic [ADDRSIZE-1:0] waddr,
   output logic [ADDRSIZE  :0] wptr,
   input  logic [ADDRSIZE  :0] wq2_rptr,
   input  logic winc, wclk, wrst_n);
  localparam DEPTH = 1<<ADDRSIZE;
  localparam factor=4;
  localparam GAP = DEPTH-DEPTH/factor;
  logic  almost_full_val;
  logic  [ADDRSIZE:0] wbin,b_rptr;
  logic [ADDRSIZE:0] wgraynext, wbinnext;
  //------------------
  // both binary and gray style pointers are stored
  //------------------
  always_ff @(posedge wclk or negedge wrst_n)
    if (!wrst_n) {wbin, wptr} <= 0;
    else         {wbin, wptr} <= {wbinnext, wgraynext};
  // b_rptr is the transformed write pointer (binary) to compute the GAP between the read and write pointers
  always_comb begin
    b_rptr[ADDRSIZE]=wq2_rptr[ADDRSIZE];
    for (int i=ADDRSIZE-1;i>=0;i--)begin
	b_rptr[i]=b_rptr[i+1]^wq2_rptr[i];
    end    
    wbinnext  = wbin + (winc & ~wfull);
    if (wbinnext-b_rptr>=GAP)begin
	almost_full_val = 1'b1;
    end
    else begin
	almost_full_val = 1'b0;
    end
  end
  assign waddr = wbin[ADDRSIZE-1:0];
  assign wgraynext = (wbinnext>>1) ^ wbinnext;
  assign wfull_val = (wgraynext=={~wq2_rptr[ADDRSIZE:ADDRSIZE-1],
                                   wq2_rptr[ADDRSIZE-2:0]});
  always_ff @(posedge wclk or negedge wrst_n)
    if (!wrst_n) begin
      wfull  <= 1'b0;
      almost_full<='0;
    end
    else begin
      wfull  <= wfull_val;
      almost_full <= almost_full_val;
      //$display("wbinnext:%d, b_rptr:%d, GAP:%d, almost_full:%b ",wbinnext, b_rptr, GAP, almost_full_val);
    end
 endmodule
