`ifndef _FIFO_TB_ENV_
`define _FIFO_TB_ENV_

import uvm_pkg::*;
`include "uvm_macros.svh" 

import fifo_pkg::*;
`include "tb_virtual_sequencer.svh"
class fifo_tb_env extends uvm_env;
	`uvm_component_utils(fifo_tb_env)

	//--------------------------------------------------------------------
	//	Component Members
	//--------------------------------------------------------------------	
	fifo_read_agent r_agent;
	fifo_write_agent w_agent;
        fifo_monitor mon;
	fifo_scoreboard score_board;
	tb_virtual_sequencer tb_v_sqr;
	coverage_collector cov_collector;

	//--------------------------------------------------------------------
	//	Methods
	//--------------------------------------------------------------------
	extern function new(string name = "fifo_tb_env", uvm_component parent= null );
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);	
endclass

// Function: new
// Definition: class constructor
function fifo_tb_env::new(string name = "fifo_tb_env", uvm_component parent = null);
	super.new(name, parent);
endfunction

// Function: build_phase
// Definition: standard uvm_phase
function void fifo_tb_env::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	r_agent = fifo_read_agent::type_id::create("r_agent", this);
	w_agent = fifo_write_agent::type_id::create("w_agent", this);
	mon = fifo_monitor::type_id::create("mon",this);
	score_board = fifo_scoreboard::type_id::create("score_board", this);
	cov_collector = coverage_collector::type_id::create("cov_collector", this);
	tb_v_sqr = tb_virtual_sequencer::type_id::create("tb_v_sqr",this);
		
endfunction: build_phase

function void fifo_tb_env::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	mon.ap.connect(cov_collector.imp);
	r_agent.read_monitor.ap.connect(score_board.model.read_imp);
	w_agent.write_monitor.ap.connect(score_board.model.write_imp);
	tb_v_sqr.r_sqr=r_agent.read_sqr;
	tb_v_sqr.w_sqr=w_agent.write_sqr;
	//r_agent.read_monitor.ap.connect(cov_collector.imp);
endfunction

`endif
