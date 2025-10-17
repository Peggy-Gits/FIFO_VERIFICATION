`ifndef FIFO_READ_MONITOR 
`define FIFO_READ_MONITOR

class fifo_read_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_read_monitor)
  virtual fifo_r_if vif;
  fifo_read_tr tr;
  uvm_analysis_port #(fifo_read_tr) ap;
  function new(string name, uvm_component parent);
    super.new(name, parent);    
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual fifo_r_if)::get(this,"", "r_vif",vif))
	`uvm_fatal(get_full_name(), "No virtual interface specified for write_driver");
    ap=new("ap",this);
  endfunction

  task run_phase(uvm_phase phase);
    @(posedge vif.rrst_n);
    //wait for reset
    forever begin
      tr = new();
      @(negedge vif.rclk);
      //uvm_report_info("write monitor","writes transaction");
      tr.rinc=vif.rinc;
      tr.rdata=vif.rdata;
      tr.rempty=vif.rempty;
      tr.almost_empty=vif.almost_empty;
      tr.raddr=vif.raddr;
      ap.write(tr);
    end
  endtask
endclass
`endif

