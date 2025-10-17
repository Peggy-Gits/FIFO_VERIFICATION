`include "fifo_data.svh"
class fifo_read_driver extends uvm_driver#(fifo_r_seq_item);
	`uvm_component_utils(fifo_read_driver)
	virtual fifo_r_if 		vif;
	fifo_r_seq_item 	 	seq_item;
	bit continuous;
	string rdata;
	//--------------------------------------------------------------------
	//	Methods
	//--------------------------------------------------------------------	
	extern function new(string name = "fifo_read_driver", uvm_component parent = null);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual task wait_for_reset();
	extern virtual task get_and_drive();
endclass

// Function: new
// Definition: class constructor
function fifo_read_driver::new(string name = "fifo_read_driver", uvm_component parent = null);
	super.new(name, parent);
endfunction: new	
	
// Function: build_phase
// Definition: standard uvm_phase
function void fifo_read_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if (!uvm_config_db#(virtual fifo_r_if)::get(this, "", "r_vif", vif)) begin
		`uvm_fatal(get_full_name(), "No virtual interface specified for read_driver")
	end 
	if (!uvm_config_db#(bit)::get(this, "", "r_cont", continuous)) begin
		`uvm_fatal(get_full_name(), "No delay configuration specified for read_driver")
	end 
endfunction: build_phase	
	
// Task: run_phase
// Definition: standard uvm_phase	
task fifo_read_driver::run_phase(uvm_phase phase);
	super.run_phase(phase);			
	wait_for_reset();
	get_and_drive();	
endtask


// Task: get_and_drive
// Definition: this task select the transfer type
task fifo_read_driver::get_and_drive();	
	forever begin
		seq_item = fifo_r_seq_item::type_id::create("seq_item",this);
		
		seq_item_port.get_next_item(seq_item);
		@(negedge vif.rclk);
		if(!continuous)begin
			for(int i=0;i<seq_item.delay;i++)begin
				vif.rinc=0;
				@(negedge vif.rclk);
			end
			vif.rinc<=1;
			@(negedge vif.rclk);
			if(vif.rempty)vif.rinc<=0;
		end
		else begin
			vif.rinc<=1;
			@(negedge vif.rclk);
			if(vif.rempty)vif.rinc<=0;
		end
		seq_item_port.item_done();
	end		
		
endtask


// Task: wait_for_reset
// Description: This class is used to wait reset signal.
task fifo_read_driver::wait_for_reset ();
	vif.rinc=0;
	wait(vif.rrst_n);	
endtask

