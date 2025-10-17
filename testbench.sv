`timescale 1ns/1ns
`include "fifo_pkg.svh"
//`include "apb_slave/apb_slave_pkg.sv"
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "tb_test.svh"
import fifo_pkg::*;
`define FIFO_SIZE 16
`define DSIZE 8
`define ASIZE 4

module top
 (fifo_if.slave port);
  logic [`DSIZE-1:0] rdata,wdata;
  //logic [`DSIZE-1:0] data [`FIFO_SIZE-1:0];
  logic winc,rinc,wrst_n,rrst_n;
  logic wclk, rclk;
  logic almost_empty, almost_full;
  logic rempty, wfull;	
  logic [`ASIZE-1:0]waddr;
  FIFO FIFO_DUT(
	.rdata(port.rdata),
        .wfull(port.wfull),
	.almost_full(port.almost_full),
        .rempty(port.rempty),
	.almost_empty(port.almost_empty),
        .wdata(port.wdata),
        .winc(port.winc), 
        .wclk(port.wclk), 
	.wrst_n(port.wrst_n),
        .rinc(port.rinc),
	.rclk(port.rclk), 
        .rrst_n(port.rrst_n));
endmodule

module testbench
#(parameter HALF_RCLK_CYCLE = 5,
  parameter HALF_WCLK_CYCLE = 2)
();
	logic rclk,wclk;
	logic rrst_n, wrst_n;	

	fifo_if  vif(.rclk(rclk), .wclk(wclk), .wrst_n(wrst_n), .rrst_n(rrst_n));
  	fifo_r_if r_vif(.rclk(rclk),.rrst_n(rrst_n));
	fifo_w_if w_vif(.wclk(wclk), .wrst_n(wrst_n));
	top top(.port(vif.slave));
	assign r_vif.rdata=vif.rdata;
	assign r_vif.rempty=vif.rempty;
	assign r_vif.almost_empty=vif.almost_empty;
	assign vif.rinc=r_vif.rinc;
	assign vif.wdata=w_vif.wdata;
	assign w_vif.wfull=vif.wfull;
	assign w_vif.almost_full=vif.almost_full;
	assign vif.winc=w_vif.winc;
	
	//Clock Generation  
    	initial begin
        	rclk = 0;
        	forever 
        	begin
            	  #(HALF_RCLK_CYCLE) rclk = ~rclk;
        	end
   	 end
	 initial begin
        	wclk = 0;
        	forever 
        	begin
            	  #(HALF_WCLK_CYCLE) wclk = ~wclk;
        	end
   	 end
	//Reset
	initial begin
		rrst_n=0; 
		wrst_n=0;
		#(4*HALF_RCLK_CYCLE); 
		rrst_n=1;
		wrst_n=1;
	end
	//Test
	initial begin
		uvm_config_db#(virtual fifo_if)::set( null, "", "vif", vif);
		uvm_config_db#(virtual fifo_r_if)::set( null, "", "r_vif", r_vif);
		uvm_config_db#(virtual fifo_w_if)::set( null, "", "w_vif", w_vif);
		uvm_top.enable_print_topology=1;
		run_test("tb_test");
	end
	initial begin
		$fsdbDumpvars;
	end
	
endmodule
