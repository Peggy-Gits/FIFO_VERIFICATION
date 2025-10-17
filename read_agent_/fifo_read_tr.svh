`ifndef FIFO_READ_TR
`define FIFO_READ_TR
class fifo_read_tr extends uvm_transaction;
  bit [`DSIZE-1:0]rdata; 
  bit [`ASIZE-1:0]raddr;
  bit almost_empty, rempty, rinc;
endclass
`endif
