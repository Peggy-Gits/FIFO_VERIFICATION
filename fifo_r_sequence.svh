`ifndef FIFO_R_SEQUENCE
`define FIFO_R_SEQUENCE
`include "fifo_r_seq_item.svh"
class fifo_r_sequence extends uvm_sequence#(fifo_r_seq_item);
	
	`uvm_object_utils(fifo_r_sequence)
	fifo_r_seq_item fifo_rseq_item;
	int length=16;
	//--------------------------------------------------------------------
	//	Methods
	//--------------------------------------------------------------------
	extern function new (string name = "fifo_rseq");
	extern task read();
	extern task body();
	extern task pre_body();
endclass

// Function: new
// Definition: class constructor	
function fifo_r_sequence::new(string name = "fifo_rseq");
	super.new(name);
endfunction
task fifo_r_sequence::read();
  fifo_rseq_item = fifo_r_seq_item::type_id::create("fifo_rseq_item");
  start_item(fifo_rseq_item);
  fifo_rseq_item.randomize() with{
  	rinc==1;
  };
  finish_item(fifo_rseq_item);
endtask
task fifo_r_sequence::pre_body();
  //uvm_config_db#(int)::get(this, "", "read_length", length);
endtask

task fifo_r_sequence::body();
  for(int i=0;i<length;i++)begin
	read();
  end
endtask: body;
`endif
