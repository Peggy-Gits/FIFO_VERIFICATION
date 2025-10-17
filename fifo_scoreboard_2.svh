`ifndef FIFO_SCOREBOARD
`define FIFO_SCOREBOARD
`include "fifo_ref_model.svh"
class fifo_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(fifo_scoreboard)
	//receiving ports
	/*uvm_analysis_imp_read #(fifo_read_tr, fifo_scoreboard)    read_imp;
	uvm_analysis_imp_write #(fifo_write_tr, fifo_scoreboard) write_imp;*/

        /*uvm_tlm_analysis_fifo #(fifo_read_tr) write_operation;
	uvm_tlm_analysis_fifo #(fifo_write_tr) read_operation;*/
	//model
	fifo_ref_model model;
	//transaction types	
	fifo_write_tr w_tr;
	fifo_read_tr r_tr;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		w_tr	= new();
		r_tr	= new();
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		model=new();
	endfunction: build_phase


endclass: fifo_scoreboard;
`endif
