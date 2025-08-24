`define DSIZE 8
`define ASIZE 4
`define NUM 40
`define DATA_SIZE 64
`define HALF_RCLK_CYCLE 5
`define HALF_WCLK_CYCLE 4

////////////////////////
//interface definition//
////////////////////////

interface r_dut_if();
  logic [`DSIZE-1:0] rdata;
  logic rinc,rclk,rrst_n;
  logic almost_empty, rempty; 
  logic [`ASIZE-1:0]raddr;
  sequence rAddress;    
    $stable(raddr);
  endsequence
  property stop_read;
    @(posedge rclk)
    (rempty&rinc)|->rAddress until $fell(rempty);
  endproperty
  aempty: assert property (stop_read);
endinterface

interface w_dut_if();
  logic [`DSIZE-1:0] wdata;
  logic winc, wrst_n, wclk;
  logic almost_full, wfull;
  logic bug_en;
  logic [`ASIZE-1:0]waddr;  
  sequence wAddress;    
    $stable(waddr);
  endsequence
  property stop_write;
     @(posedge wclk)
    (wfull&winc)|=>wAddress until $fell(wfull);
  endproperty
  afull: assert property (stop_write);
endinterface

//////////////////////////
//transaction definition//
//////////////////////////

class rtransaction;
  bit almost_empty, rempty, rinc;
  bit [`DSIZE-1:0] rdata;
  function new();
  endfunction  
endclass

class wtransaction;
  bit almost_full, wfull, winc;
  bit [`DSIZE-1:0] wdata;
  bit bug_en;
  function new();
  endfunction
endclass

//////////////////////
//monitor definition//
//////////////////////

class rmonitor;
 virtual r_dut_if r_dut_vif;
 rtransaction txn;
 mailbox #(rtransaction) txn_mail;
 function new(virtual r_dut_if r_dut_vif);
   this.r_dut_vif = r_dut_vif;
 endfunction 
 task run();
   forever begin     
     @(posedge r_dut_vif.rclk);
     txn = new();
     txn.rinc=r_dut_vif.rinc&r_dut_vif.rrst_n&~r_dut_vif.rempty;
     @(negedge r_dut_vif.rclk);
     txn.rdata=r_dut_vif.rdata;
     txn.rempty=r_dut_vif.rempty;
     txn.almost_empty=r_dut_vif.almost_empty; 
     txn_mail.put(txn);
    end
 endtask
endclass

class wmonitor;
 virtual w_dut_if w_dut_vif;
 mailbox #(wtransaction) txn_mail;
 wtransaction txn;
 function new(virtual w_dut_if w_dut_vif);
   this.w_dut_vif = w_dut_vif;
 endfunction 
 task run();
    forever begin     
     @(posedge w_dut_vif.wclk);
     txn = new();
     txn.winc=(w_dut_vif.winc^w_dut_vif.bug_en)&w_dut_vif.wrst_n&(~w_dut_vif.wfull);
     txn.wdata=w_dut_vif.wdata;
     @(negedge w_dut_vif.wclk);
     txn.wfull=w_dut_vif.wfull;
     txn.almost_full=w_dut_vif.almost_full;
     txn_mail.put(txn);
    end
 endtask
endclass

/////////////////////////
//scoreboard definition//
/////////////////////////

class scoreboard;
  mailbox #(rtransaction) rtxn_mail;
  mailbox #(wtransaction) wtxn_mail;
  rtransaction rtxn;
  wtransaction wtxn;
  int rdata_gold;
  int bounded_q[$:`NUM];
  int nth_read;
  int nth_write;

  function print_queue();
    $display("##%d,%d,%d,%d,%d.",bounded_q[0],bounded_q[1],bounded_q[2],bounded_q[3],bounded_q[4]);    
  endfunction

  task rrun();
    nth_read=0;
    forever begin
      rtxn_mail.get(rtxn);
      //print_queue();
      //rdata_gold=bounded_q[0];
      if(rtxn.rinc)begin
	bounded_q.pop_front();
        nth_read=nth_read+1;
      end      
      rdata_gold=bounded_q[0];
      if(rdata_gold!=rtxn.rdata)
        $display("wrong read data:%d, expect: %d", rtxn.rdata,rdata_gold);
      else 
        $display("%d th read: %d", nth_read, rtxn.rdata);
      if((bounded_q.size()==0)^rtxn.rempty)
        $error("empty: %d", rtxn.rempty);
      /*if((bounded_q.size()<=4)^rtxn.almost_empty)
        $error("almost empty: %d", rtxn.almost_empty);*/
    end
  endtask
  task wrun();
    nth_write=0;
    forever begin
      wtxn_mail.get(wtxn);
      if(wtxn.winc)begin 
	bounded_q.push_back(wtxn.wdata);
       // $display("write in:%d", wtxn.wdata);
        nth_write=nth_write+1;
      end
      if((bounded_q.size()==16)^wtxn.wfull)
        $error("wfull:%d", wtxn.wfull);
      end
      if((bounded_q.size()>=4)^wtxn.almost_full)
        $error("almost full: %d", wtxn.almost_full);
  endtask
endclass

/////////////
//testbench//
/////////////

module FIFO_testbench();
  logic [`DSIZE-1:0] rdata,wdata;
  logic [`DSIZE-1:0] data [`DATA_SIZE-1:0];
  logic winc,rinc,wrst_n,rrst_n;
  logic wclk, rclk;
  logic almost_empty, almost_full;
  logic rempty, wfull;	
  int q,w_num;
  bit bug_en;
  logic [`ASIZE-1:0]waddr;

  r_dut_if r_dut_if_inst();
  w_dut_if w_dut_if_inst();
  assign w_dut_if_inst.wdata=wdata;
  assign w_dut_if_inst.wclk=wclk;
  assign r_dut_if_inst.rclk=rclk;
  assign r_dut_if_inst.rrst_n=rrst_n;
  assign w_dut_if_inst.wrst_n=wrst_n;
  assign r_dut_if_inst.rinc=rinc;
  assign w_dut_if_inst.winc=winc;
  assign rempty=r_dut_if_inst.rempty;
  assign rdata=r_dut_if_inst.rdata;
  assign almost_empty=r_dut_if_inst.almost_empty;
  assign wfull=w_dut_if_inst.wfull;
  assign almost_full=w_dut_if_inst.almost_full;
  assign w_dut_if_inst.bug_en=bug_en;
  assign waddr=FIFO_DUT.wptr_full.waddr;
  assign w_dut_if_inst.waddr=waddr;
  assign r_dut_if_inst.raddr=FIFO_DUT.rptr_empty.raddr;
////////////////////////
//read and write tasks//
////////////////////////
  task write(int num);
     begin
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
     bug_en=0;
     for(int i=0;i<num;i++)begin
       @(negedge wclk);          
          w_num=w_num+1;
          bug_en=w_num%4==0;
          winc=1'b1&(~bug_en);
          wdata=data[i];
       end
     @(negedge wclk);
     winc=1'b0;
     bug_en=0;
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
   
   task assert_full;
      read(2);
      write(17);
      read(5);
      write(5);
   endtask

   task bug;
     bug_write(16);
     read(16);
   endtask
//////////////////
//CLK generation//
//////////////////
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
///////////////////////
//instantiate the dut//
///////////////////////
  FIFO FIFO_DUT(
	.rdata(r_dut_if_inst.rdata),
        .wfull(w_dut_if_inst.wfull),
	.almost_full(w_dut_if_inst.almost_full),
        .rempty(r_dut_if_inst.rempty),
	.almost_empty(r_dut_if_inst.almost_empty),
        .wdata(w_dut_if_inst.wdata),
        .winc(w_dut_if_inst.winc), 
        .wclk(w_dut_if_inst.wclk), 
	.wrst_n(w_dut_if_inst.wrst_n),
        .rinc(r_dut_if_inst.rinc),
	.rclk(r_dut_if_inst.rclk), 
        .rrst_n(r_dut_if_inst.rrst_n));
////////////////////////////////////
//construct monitor and scoreboard//
////////////////////////////////////
   wmonitor wmon;
   rmonitor rmon;
   scoreboard sb;
   mailbox #(rtransaction) rtxn_mail;
   mailbox #(wtransaction) wtxn_mail;
  initial begin
     sb = new();
     rmon = new(r_dut_if_inst);
     wmon = new(w_dut_if_inst);
     rtxn_mail = new();
     wtxn_mail = new();
     rmon.txn_mail = rtxn_mail;
     sb.rtxn_mail = rtxn_mail;
     wmon.txn_mail = wtxn_mail;
     sb.wtxn_mail = wtxn_mail;
     fork
       rmon.run();
       wmon.run();
       sb.wrun();
       sb.rrun();
     join
   end
   initial begin
     $fsdbDumpvars();
   end 
   initial begin
        //prepare data
        $readmemh("memfile.dat",data);
   end
   always@(rclk) begin
       q=sb.rdata_gold;
   end
////////////////////
//simulate the dut//
////////////////////
   int scenario;
   initial begin
     //reset fifo
     rrst_n=1'b0;
     wrst_n=1'b0;
     @(negedge rclk);
     wrst_n=1'b1;
     rrst_n=1'b1;
     winc=1'b0;
     rinc=1'b0;
     //choose simulation scenarios
     if(!$test$plusargs("test"))begin
	$display("no test");
        $finish;
     end
     $value$plusargs("test=%d",scenario);
     case(scenario)
       1:assert_full();
       2:bug();
     endcase
     #10;     
     $display("fifo empty");
     $finish;
   end
endmodule

