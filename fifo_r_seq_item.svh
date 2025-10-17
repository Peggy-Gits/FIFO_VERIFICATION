`ifndef _FIFO_R_SEQ_ITEM_
`define _FIFO_R_SEQ_ITEM_

class fifo_r_seq_item extends uvm_sequence_item;
	`uvm_object_utils(fifo_r_seq_item)
	//--------------------------------------------------------------------
	//	Data Members
	//--------------------------------------------------------------------	
	rand bit rinc;   
	rand int delay;	
	
	// constraint
	constraint c_delay { delay inside {[0:2]}; }; 
	//--------------------------------------------------------------------
	//	Methods
	//--------------------------------------------------------------------		
	extern function new(string name = "fifo_r_seq_item");
	extern function string get_content();
endclass

// Function: new
// Definition: class constructor
function fifo_r_seq_item::new (string name = "fifo_r_seq_item");
	super.new(name);
endfunction
function string fifo_r_seq_item::get_content ();
	return $psprintf("\n \
-------------------------READ_TRANSFER----------------------------- \n \
READ.=%b \n \
DELAY=%0h \n \
--------------------------------------------------------------",rinc,delay);
endfunction: get_content;

`endif
