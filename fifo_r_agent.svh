`ifndef _FIFO_READ_AGENT_
`define _FIFO_READ_AGENT_

class fifo_read_agent extends uvm_agent;
	`uvm_component_utils(fifo_read_agent)
	//--------------------------------------------------------------------
	//	Component Members
	//--------------------------------------------------------------------	
	fifo_read_driver  							read_driver;
	fifo_read_monitor							read_monitor;
	fifo_read_sequencer							read_sqr;
	//--------------------------------------------------------------------
	//	Methods
	//--------------------------------------------------------------------
	extern function new(string name = "read_agent", uvm_component parent );
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);	
endclass

// Function: new
// Definition: class constructor
function fifo_read_agent::new(string name = "read_agent", uvm_component parent);
	super.new(name, parent);
endfunction: new

// Function: build_phase
// Definition: standard uvm_phase
function void fifo_read_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	read_monitor	= fifo_read_monitor::type_id::create("read_monitor",this);
	read_driver	= fifo_read_driver::type_id::create("read_driver",this);
	read_sqr	= fifo_read_sequencer::type_id::create("read_sqr",this);
endfunction: build_phase

	
// Function: connect_phase
// Definition: standard uvm_phase	
function void fifo_read_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	read_driver.seq_item_port.connect(read_sqr.seq_item_export);
endfunction	

`endif
