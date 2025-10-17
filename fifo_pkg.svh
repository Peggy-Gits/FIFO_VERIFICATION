`ifndef _FIFO_PKG_
`define _FIFO_PKG_
	
package fifo_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	`include "fifo_r_seq_item.svh"
	`include "fifo_w_seq_item.svh"
	`include "fifo_tr.svh"
	`include "fifo_write_tr.svh"
	`include "fifo_read_tr.svh"
	`include "fifo_w_sequence.svh"
	`include "fifo_r_sequence.svh"
	`include "fifo_write_sequencer.svh"
	`include "fifo_read_sequencer.svh"
	`include "fifo_write_monitor.svh"
	`include "fifo_read_monitor.svh"
	`include "fifo_write_driver.svh"
	`include "fifo_read_driver.svh"
	`include "fifo_monitor.svh"
	`include "fifo_w_agent.svh"
	`include "fifo_r_agent.svh"
	`include "coverage_collector.svh"
	`include "fifo_scoreboard_2.svh"
	`include "fifo_tb_env.svh"
	`include "fifo_read_sequencer.svh"
	`include "fifo_write_sequencer.svh"
	`include "tb_virtual_sequencer.svh"
	`include "tb_virtual_seq.svh"
	`include "fifo_data.svh"
	`include "ideal_fifo.svh"
	`include "fifo_ref_model.svh"
	`include "coverage_collector.svh"
endpackage

`endif
