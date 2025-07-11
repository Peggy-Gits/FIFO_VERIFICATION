 module FIFO#(parameter DSIZE = 8,
               parameter ASIZE = 4)
  (output logic [DSIZE-1:0] rdata,
   output logic       wfull,
   output logic       rempty,
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
                           .raddr(raddr),
                           .rptr(rptr), .rq2_wptr(rq2_wptr),
                           .rinc(rinc), .rclk(rclk),
                           .rrst_n(rrst_n));
  FULL #(ASIZE)     wptr_full
                          (.wfull(wfull), .waddr(waddr),
                           .wptr(wptr), .wq2_rptr(wq2_rptr),
                           .winc(winc), .wclk(wclk),
                           .wrst_n(wrst_n));
 endmodule
