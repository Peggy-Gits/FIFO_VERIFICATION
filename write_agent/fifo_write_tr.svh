`ifndef FIFO_WRITE_TR
`define FIFO_WRITE_TR
`define ASIZE 4
class fifo_write_tr extends uvm_transaction;
  bit [`DSIZE-1:0]wdata; 
  bit [`ASIZE-1:0]waddr;
  bit almost_full, wfull, winc;
endclass
`endif
