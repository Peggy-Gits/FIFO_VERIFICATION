`ifndef FIFO_W_SEQUENCE
`define FIFO_W_SEQUENCE
`include "fifo_w_seq_item.svh"
`include "fifo_data.svh"
class fifo_w_sequence extends uvm_sequence#(fifo_w_seq_item);
	
	`uvm_object_utils(fifo_w_sequence)
	fifo_w_seq_item fifo_wseq_item;
	fifo_data data; 
	//--------------------------------------------------------------------
	//	Methods
	//--------------------------------------------------------------------
	extern function new (string name = "fifo_wseq");
	extern task write(int dat);
	extern task body();
	extern task pre_body();
endclass

// Function: new
// Definition: class constructor	
function fifo_w_sequence::new(string name ="fifo_wseq");
	super.new(name);
	data=new("mem.dat");	
endfunction

task fifo_w_sequence::pre_body();
	//uvm_config_db#(fifo_data)::get(this, "", "data", data);
	//$readmemh("mem.dat",data.mem);
endtask

task fifo_w_sequence::write(int dat);
  fifo_wseq_item = fifo_w_seq_item::type_id::create("fifo_wseq_item");
  start_item(fifo_wseq_item);
  fifo_wseq_item.randomize() with{
  	winc==1;
	wdata==dat;
  };
  finish_item(fifo_wseq_item);
endtask

task fifo_w_sequence::body();
  for(int i=0;i<data.write_length;i++)begin
	write(data.mem[i]);
  end
  
endtask: body;
`endif
