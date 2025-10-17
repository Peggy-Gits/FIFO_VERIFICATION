`ifndef FIFO_WRITE_SEQUENCER
`define FIFO_WRITE_SEQUENCER
class fifo_write_sequencer extends uvm_sequencer#(fifo_w_seq_item);

	`uvm_component_utils(fifo_write_sequencer)

	function new(string name = "fifo_write_sequencer", uvm_component parent = null);
		super.new(name, parent);
	endfunction


endclass
`endif
