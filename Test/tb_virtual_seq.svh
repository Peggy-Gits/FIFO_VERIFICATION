`ifndef _TB_VIRTUAL_SEQ_
`define _TB_VIRTUAL_SEQ_
//`include "tb_virtual_seq.svh"
class tb_virtual_seq extends uvm_sequence;
	`uvm_object_utils(tb_virtual_seq)
	`uvm_declare_p_sequencer(tb_virtual_sequencer);

	fifo_r_sequence r_seq;
	fifo_w_sequence w_seq;
	//--------------------------------------------------------------------
	//	Methods
	//--------------------------------------------------------------------
	extern function new (string name = "tb_virtual_seq",uvm_component parent = null);
	extern task pre_body();
	extern task body();
endclass

// Function: new
// Definition: class constructor	
function tb_virtual_seq::new(string name ="tb_virtual_seq",uvm_component parent = null);
	super.new(name);	
endfunction

task tb_virtual_seq::pre_body();
	r_seq = fifo_r_sequence::type_id::create("r_seq");
	w_seq = fifo_w_sequence::type_id::create("w_seq");
endtask
// Function: body
// Definition: body method that gets executed once sequence is started 
task tb_virtual_seq::body();
  fork
	r_seq.start(p_sequencer.r_sqr);
	w_seq.start(p_sequencer.w_sqr);	
  join
endtask

`endif
