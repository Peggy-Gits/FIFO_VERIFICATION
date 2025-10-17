`ifndef FIFO_R_IF
`define FIFO_R_IF
interface fifo_r_if(input logic rclk, rrst_n);
  logic [`DSIZE-1:0] rdata;
  logic rinc,rclk,rrst_n;
  logic almost_empty, rempty; 
  logic [`ASIZE-1:0]raddr;
  modport master(input rdata, almost_empty, rempty, rclk, rrst_n, output rinc);
  modport slave(output rdata, almost_empty, rempty, input rclk, rrst_n, rinc);
  sequence rAddress;    
    $stable(raddr);
  endsequence
  property stop_read;
    @(posedge rclk)
    (rempty&rinc)|->rAddress until $fell(rempty);
  endproperty
  aempty: assert property (stop_read);
endinterface
`endif
