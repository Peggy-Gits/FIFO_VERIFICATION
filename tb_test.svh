`ifndef _TB_TEST_
`define _TB_TEST_

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fifo_pkg.svh"
import fifo_pkg::*;
`define MEM_SIZE 1024
`define READ_LENGTH 40
`define WRITE_LENGTH 80
class tb_test extends uvm_test;
	
	//Register with factory
	`uvm_component_utils(tb_test)
  	
	fifo_tb_env  env;
	fifo_data data;
	int read_length;
	int write_length;
	bit r_cont, w_cont;
	tb_virtual_seq tb_v_seq;
	//--------------------------------------------------------------------
	//	Methods
	//--------------------------------------------------------------------
	extern function new(string name = "tb_test", uvm_component parent = null );
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);  


endclass

// Function: new
// Definition: class constructor
function tb_test::new(string name = "tb_test", uvm_component parent = null);
	super.new(name, parent);
	read_length=`READ_LENGTH;
	write_length=`WRITE_LENGTH;
endfunction

// Function: build_phase
// Definition: standard uvm_phase
function void tb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	env = fifo_tb_env::type_id::create("env", this);
	data = fifo_data::new("mem.dat");
	data.write_length=write_length;
	uvm_config_db#(fifo_data)::set(this, "tb_v_seq.w_seq","data", data);
	uvm_config_db#(bit)::set(this, "env.r_agent.read_driver","r_cont", r_cont);
	uvm_config_db#(int)::set(this, "tb_v_seq.r_seq","read_length", read_length);
	uvm_config_db#(bit)::set(this, "env.w_agent.write_driver","w_cont", w_cont);
	tb_v_seq = tb_virtual_seq::type_id::create("tb_v_seq");	
	
endfunction

// Task: run_phase
// Definition: standard uvm_phase	
task tb_test::run_phase( uvm_phase phase );
	super.run_phase(phase);
	
	phase.raise_objection( this, "Starting fifo_test run phase" );
		tb_v_seq.start(env.tb_v_sqr);	
		#10;
	phase.drop_objection( this , "Finished fifo_test in run phase" );
	
endtask: run_phase	

`endif
