`ifndef FIFO_READ_SEQUENCER
`define FIFO_READ_SEQUENCER
class fifo_read_sequencer extends uvm_sequencer#(fifo_r_seq_item);

	`uvm_component_utils(fifo_read_sequencer)

	function new(string name = "fifo_read_sequencer", uvm_component parent = null);
		super.new(name, parent);
	endfunction


endclass
`endif
