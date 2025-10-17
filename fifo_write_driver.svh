`include "fifo_data.svh"
class fifo_write_driver extends uvm_driver#(fifo_w_seq_item);
	`uvm_component_utils(fifo_write_driver)
	virtual fifo_w_if 		vif;
	fifo_w_seq_item 	 	seq_item;
	bit continuous;
	string rdata;
	//--------------------------------------------------------------------
	//	Methods
	//--------------------------------------------------------------------	
	extern function new(string name = "fifo_write_driver", uvm_component parent = null);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual task wait_for_reset();
	extern virtual task get_and_drive();
endclass

// Function: new
// Definition: class constructor
function fifo_write_driver::new(string name = "fifo_write_driver", uvm_component parent = null);
	super.new(name, parent);
endfunction: new	
	
// Function: build_phase
// Definition: standard uvm_phase
function void fifo_write_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if (!uvm_config_db#(virtual fifo_w_if)::get(this, "", "w_vif", vif)) begin
		`uvm_fatal(get_full_name(), "No virtual interface specified for write_driver");
	end 
	if (!uvm_config_db#(bit)::get(this, "", "w_cont", continuous)) begin
		`uvm_fatal(get_full_name(), "No delay configuration specified for write_driver");
	end 
endfunction: build_phase	
	
// Task: run_phase
// Definition: standard uvm_phase	
task fifo_write_driver::run_phase(uvm_phase phase);
	super.run_phase(phase);			
	wait_for_reset();
	$display("write_continuous?%b",continuous);
	get_and_drive();	
endtask


// Task: get_and_drive
// Definition: this task select the transfer type
task fifo_write_driver::get_and_drive();	
	forever begin
		seq_item = fifo_w_seq_item::type_id::create("seq_item",this);
		
		seq_item_port.get_next_item(seq_item);
		//$display("can_write:%d\n",seq_item.delay);
		@(negedge vif.master.wclk);
		
		if(!continuous)begin
			//$display("can_write:%d\n",seq_item.delay);
			for(int i=0;i<seq_item.delay;i++)begin
				vif.master.winc=0;
				@(negedge vif.wclk);
			end			
			vif.master.winc<=1;
			vif.master.wdata=seq_item.wdata;
			@(negedge vif.master.wclk);
			if(vif.slave.wfull)vif.master.winc<=0;
		end
		else begin
			//$display("can_write:%d\n",seq_item.delay);
			vif.master.winc<=1;
			vif.master.wdata=seq_item.wdata;
			@(negedge vif.master.wclk);
			if(vif.slave.wfull)vif.master.winc<=0;
		end
		seq_item_port.item_done();
	end		
		
endtask


// Task: wait_for_reset
// Description: This class is used to wait reset signal.
task fifo_write_driver::wait_for_reset ();
	vif.master.winc=0;
	wait(vif.master.wrst_n);	
endtask
