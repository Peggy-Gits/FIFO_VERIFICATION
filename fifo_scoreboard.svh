`ifndef FIFO_SCOREBOARD
`define FIFO_SCOREBOARD
`include "ideal_fifo.svh"
`include "fifo_ref_model.svh"
`uvm_analysis_imp_decl(_read)
`uvm_analysis_imp_decl(_write)
class fifo_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(fifo_scoreboard)
	//receiving ports
	uvm_analysis_imp_read #(fifo_read_tr, fifo_scoreboard)    read_imp;
	uvm_analysis_imp_write #(fifo_write_tr, fifo_scoreboard) write_imp;

        /*uvm_tlm_analysis_fifo #(fifo_read_tr) write_operation;
	uvm_tlm_analysis_fifo #(fifo_write_tr) read_operation;*/
	//model
	ideal_fifo model;
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
		read_imp  = new("read_imp",this);
		write_imp = new("write_imp", this);
		model=new();
	endfunction: build_phase

	function void write_read(fifo_read_tr t);
		if(t.rinc==1&&(!t.rempty))begin 
			model.read();
		  if(rdata!=t.rdata)
		  `uvm_info(get_type_name(),$sformatf("expect: %d, read %d", t.rdata, rdata),UVM_MEDIUM);
		end
	endfunction
	function void write_write(fifo_write_tr t);
		if(t.winc==1&&(!t.wfull))model.write(t.wdata);		
	endfunction

endclass: fifo_scoreboard;
`endif
