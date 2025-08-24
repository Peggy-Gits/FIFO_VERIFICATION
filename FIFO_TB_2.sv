`define DSIZE 8
`define ASIZE 4
`define NUM 40
`define DATA_SIZE 64
`define HALF_RCLK_CYCLE 5
`define HALF_WCLK_CYCLE 4
`define BUG_RATE 4

import "DPI-C" function int pop();
import "DPI-C" function int front();
import "DPI-C" function void push(int val);
import "DPI-C" function logic is_empty();
import "DPI-C" function logic is_full();
import "DPI-C" function logic near_empty();
import "DPI-C" function logic near_full();
import "DPI-C" function void rreset();
import "DPI-C" function void wreset();

////////////////////////
//interface definition//
////////////////////////
interface dut_if();
  logic [`DSIZE-1:0] rdata,wdata;
  logic winc,rinc,wrst_n,rrst_n;
  logic wclk, rclk;
  logic almost_empty, almost_full;
  logic rempty, wfull;	
endinterface

//////////////////////
//checker definition//
//////////////////////

module check
(input logic [`DSIZE-1:0]rdata, wdata,
 input logic wclk, rclk, rinc, winc,
 input logic almost_empty, rempty,
 input logic wfull, almost_full,
 input logic rrst_n,wrst_n,
 input logic bug_en);
  
  int rdata_gold;
  logic almost_empty_gold, rempty_gold;
  logic almost_full_gold, wfull_gold;
  always begin
    @(posedge rclk);
     if(rrst_n==1'b0)rreset();
     else begin
       if(rinc&rrst_n&(~rempty))pop();
       rdata_gold=front();
       almost_empty_gold=near_empty();
       rempty_gold=is_empty();
     end
    @(negedge rclk);
    if(rdata!=rdata_gold)$error("wrong data: %d, expected data %d", rdata, rdata_gold);
    else $display("read data %d:",rdata);
    //if(almost_empty!=almost_empty_gold)$error("almost empty flag: %b", almost_empty_gold);
    if(rempty!=rempty_gold)$error("rempty flag: %b", rempty_gold);     
  end
  always begin
    @(posedge wclk);
     if(wrst_n==1'b0)begin 
       wreset();
     end
     else begin
       if(wrst_n&(~wfull)&(winc^bug_en))push(wdata);
       almost_full_gold=near_full();
       wfull_gold=is_full();
     end
    @(negedge wclk);
     //if(almost_full!=almost_full_gold)$error("almost full flag: %b", almost_full_gold);
     if(wfull!=wfull_gold)$error("wfull flag: %b", wfull_gold);     
  end
endmodule

////////////////////////
//testbench definition//
////////////////////////

module FIFO_testbench_dpi
  #(parameter DSIZE = 8,
    parameter ASIZE = 4,
    parameter R_HALF_CLOCK_CYCLE = 2,
    parameter W_HALF_CLOCK_CYCLE = 1)
();
  logic [`DSIZE-1:0] rdata,wdata;
  logic winc,rinc,wrst_n,rrst_n;
  logic wclk, rclk;
  logic almost_empty, almost_full;
  logic rempty, wfull;	
  logic [`DSIZE-1:0] data [`DATA_SIZE-1:0];
  logic bug_en;
  int w_num;

  dut_if dut_if_inst();
  assign dut_if_inst.wdata=wdata;
  assign dut_if_inst.wclk=wclk;
  assign dut_if_inst.rclk=rclk;
  assign dut_if_inst.rrst_n=rrst_n;
  assign dut_if_inst.wrst_n=wrst_n;
  assign dut_if_inst.rinc=rinc;
  assign dut_if_inst.winc=winc;
  assign rempty=dut_if_inst.rempty;
  assign almost_empty=dut_if_inst.almost_empty;
  assign rdata=dut_if_inst.rdata;
  assign wfull=dut_if_inst.wfull;
  assign almost_full=dut_if_inst.almost_full;
////////////////////////
//read and write tasks//
////////////////////////
  task write(int num);
     begin
        bug_en='0;
	for(int i=0;i<num;i++)begin
	  @(negedge wclk); 
          winc=1'b1;
          wdata=data[i];
	end
        @(negedge wclk);
	winc=1'b0;
     end
   endtask
   
   task bug_write(int num);
     begin
        bug_en='0;
	for(int i=0;i<num;i++)begin
	  @(negedge wclk);          
          w_num=w_num+1;
          bug_en=w_num%4==0;
          winc=1'b1&(~bug_en);
          wdata=data[i];
	end
        @(negedge wclk);
	winc=1'b0;
        bug_en='0;
     end
   endtask

   task read(int num);
     begin
	for(int i=0;i<num;i++)begin
	  @(negedge rclk);
          rinc=1'b1;
        end
        @(negedge rclk);
        rinc=1'b0;
     end
   endtask
//////////////////
//scenario tasks//
////////////////// 
   task basic;
      fork
	write(`NUM);
        read(`NUM);
      join
   endtask

   task bug;
      bug_write(16);
      read(16);
   endtask
//////////////////
//CLK generation//
//////////////////
   /*initial begin
     rclk=1'b0;
     forever begin
	rclk=~rclk;
        #(`HALF_RCLK_CYCLE);
     end
   end

   initial begin
     wclk=1'b0;
     @(negedge rclk);
     forever begin
	wclk=~wclk;
        #(`HALF_WCLK_CYCLE);
     end
   end*/
  initial begin
   rclk=1'b0;
   forever #(`HALF_RCLK_CYCLE)rclk=~rclk;
  end
  initial begin
   wclk=1'b0;
   @(posedge rclk);
   forever begin 
     wclk=~wclk;
     #(`HALF_WCLK_CYCLE);
   end
  end


///////////////////////////////////
//instantiate the checker and dut//
///////////////////////////////////
  check dut_check(
        .rdata(dut_if_inst.rdata),
        .wfull(dut_if_inst.wfull),
	.almost_full(dut_if_inst.almost_full),
        .rempty(dut_if_inst.rempty),
	.almost_empty(dut_if_inst.almost_empty),
        .wdata(dut_if_inst.wdata),
        .winc(dut_if_inst.winc), 
        .wclk(dut_if_inst.wclk), 
	.wrst_n(dut_if_inst.wrst_n),
        .rinc(dut_if_inst.rinc),
	.rclk(dut_if_inst.rclk), 
        .rrst_n(dut_if_inst.rrst_n),
        .bug_en(bug_en)
   );

  FIFO FIFO_DUT(
	.rdata(dut_if_inst.rdata),
        .wfull(dut_if_inst.wfull),
	.almost_full(dut_if_inst.almost_full),
        .rempty(dut_if_inst.rempty),
	.almost_empty(dut_if_inst.almost_empty),
        .wdata(dut_if_inst.wdata),
        .winc(dut_if_inst.winc), 
        .wclk(dut_if_inst.wclk), 
	.wrst_n(dut_if_inst.wrst_n),
        .rinc(dut_if_inst.rinc),
	.rclk(dut_if_inst.rclk), 
        .rrst_n(dut_if_inst.rrst_n)
   );
   
   initial begin
     $fsdbDumpvars();
   end 

   initial begin
        //prepare data
        $readmemh("memfile.dat",data);
   end
////////////////////
//simulate the dut//
////////////////////
   int scenario;
   initial begin
     //reset the dut
     rrst_n=1'b0;
     wrst_n=1'b0;
     @(negedge rclk);
     wrst_n=1'b1;
     rrst_n=1'b1;
     winc=1'b0;
     rinc=1'b0;
     if(!$test$plusargs("test"))begin
	$display("no test");
        $finish;
     end
     $value$plusargs("test=%d",scenario);
     case(scenario)
       1:basic();
       2:bug();
     endcase
     #10;     
     $display("fifo empty");
     $finish;
  end
endmodule



