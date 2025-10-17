`ifndef FIFO_MONITOR 
`define FIFO_MONITOR

class fifo_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_monitor)
  virtual fifo_if vif;
  fifo_tr tr;
  uvm_analysis_port #(fifo_tr) ap;
  function new(string name, uvm_component parent);
    super.new(name, parent);    
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual fifo_if)::get(this,"", "vif",vif))
	`uvm_fatal(get_full_name(), "No virtual interface specified for the monitor");
    ap=new("ap",this);
  endfunction
  task run_read();
     @(posedge vif.rrst_n);
    //wait for reset
	uvm_report_info("MONITOR","START");
    forever begin
      tr = new();
      @(posedge vif.rclk);
      tr.rinc=vif.rinc;
      tr.winc=vif.winc;
      @(negedge vif.rclk);
      tr.rdata=vif.rdata;
      tr.rempty=vif.rempty;
      tr.almost_empty=vif.almost_empty;
      uvm_report_info("MONITOR",$psprintf("READ %s",tr.get_content()));
      ap.write(tr);
    end
  endtask

  task run_write();
     @(posedge vif.wrst_n);
    //wait for reset
    forever begin
      tr = new();
      @(posedge vif.wclk);
      tr.winc=vif.winc;
      tr.rinc=vif.rinc;
      tr.wdata=vif.wdata;
      @(negedge vif.wclk);
      tr.wfull=vif.wfull;
      tr.almost_full=vif.almost_full;
      uvm_report_info("MONITOR",$psprintf("WRITE %s",tr.get_content()));
      ap.write(tr);
    end
  endtask

  task run_phase(uvm_phase phase);
    fork
	run_read();
	run_write();
    join
  endtask
endclass
`endif
