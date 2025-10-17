`ifndef TB_VIRTUAL_SEQUENCER
`define TB_VIRTUAL_SEQUENCER
class tb_virtual_sequencer extends uvm_sequencer;

	`uvm_component_utils(tb_virtual_sequencer)
	fifo_read_sequencer r_sqr;
	fifo_write_sequencer w_sqr;
	function new(string name = "tb_virtual_sequencer", uvm_component parent = null);
		super.new(name, parent);
	endfunction


endclass
`endif
