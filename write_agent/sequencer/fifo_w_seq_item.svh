`ifndef _FIFO_W_SEQ_ITEM_
`define _FIFO_W_SEQ_ITEM_
`define DSIZE 8
class fifo_w_seq_item extends uvm_sequence_item;
	`uvm_object_utils(fifo_w_seq_item)
	//--------------------------------------------------------------------
	//	Data Members
	//--------------------------------------------------------------------	
	rand bit winc;   
	rand int delay;	
	rand bit [`DSIZE-1:0] wdata;
	int length;
	// constraint
	constraint c_delay { delay inside {[0:2]}; }; 
	//--------------------------------------------------------------------
	//	Methods
	//--------------------------------------------------------------------		
	extern function new(string name = "fifo_w_seq_item");
endclass

// Function: new
// Definition: class constructor
function fifo_w_seq_item::new (string name = "fifo_w_seq_item");
	super.new(name);
endfunction
`endif
