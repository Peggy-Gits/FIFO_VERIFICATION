`ifndef _FIFO_WRITE_AGENT_
`define _FIFO_WRITE_AGENT_

class fifo_write_agent extends uvm_agent;
	`uvm_component_utils(fifo_write_agent)
	//--------------------------------------------------------------------
	//	Component Members
	//--------------------------------------------------------------------	
	fifo_write_driver  							write_driver;
	fifo_write_monitor							write_monitor;
	fifo_write_sequencer							write_sqr;
	//--------------------------------------------------------------------
	//	Methods
	//--------------------------------------------------------------------
	extern function new(string name = "write_agent", uvm_component parent );
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);	
endclass

// Function: new
// Definition: class constructor
function fifo_write_agent::new(string name = "write_agent", uvm_component parent);
	super.new(name, parent);
endfunction: new

// Function: build_phase
// Definition: standard uvm_phase
function void fifo_write_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	write_monitor	= fifo_write_monitor::type_id::create("write_monitor",this);
	write_driver	= fifo_write_driver::type_id::create("write_driver",this);
	write_sqr	= fifo_write_sequencer::type_id::create("write_sqr",this);
endfunction: build_phase

	
// Function: connect_phase
// Definition: standard uvm_phase	
function void fifo_write_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	write_driver.seq_item_port.connect(write_sqr.seq_item_export);
endfunction	

`endif
