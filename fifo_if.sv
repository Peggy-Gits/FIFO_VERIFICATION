`ifndef FIFO_IF
`define FIFO_IF
interface fifo_if(input bit wclk, rclk, rrst_n, wrst_n);
  logic [`DSIZE-1:0] rdata, wdata;
  logic rinc,winc;
  logic almost_empty, rempty, wfull, almost_full; 
  modport slave (input wclk, rclk, rrst_n, wrst_n, wdata, rinc, winc, 
		output rdata, rempty, almost_empty, wfull, almost_full);
  modport master (input wclk, rclk, rrst_n, wrst_n, rdata, rempty, almost_empty, wfull, almost_full,
		output rinc, winc, wdata);
endinterface
`endif
