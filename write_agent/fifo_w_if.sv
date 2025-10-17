`ifndef FIFO_W_IF
`define FIFO_W_IF
interface fifo_w_if(input bit wclk, wrst_n);
  logic [`DSIZE-1:0] wdata;
  logic winc;
  logic almost_full, wfull;
  logic [`ASIZE-1:0]waddr;  
  modport slave(output wfull, almost_full, input wrst_n, wclk, winc, waddr, wdata);
  modport master(input wclk, wrst_n, almost_full, wfull, output waddr, wdata, winc);
  sequence wAddress;    
    $stable(waddr);
  endsequence
  property stop_write;
     @(posedge wclk)
    (wfull&winc)|=>wAddress until $fell(wfull);
  endproperty
  afull: assert property (stop_write);
endinterface
`endif
