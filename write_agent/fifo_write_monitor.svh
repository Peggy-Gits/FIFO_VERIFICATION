`ifndef FIFO_WRITE_MONITOR 
`define FIFO_WRITE_MONITOR

class fifo_write_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_write_monitor)
  virtual fifo_w_if vif;
  fifo_write_tr tr;
  uvm_analysis_port #(fifo_write_tr) ap;
  function new(string name, uvm_component parent);
    super.new(name, parent);    
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual fifo_w_if)::get(this,"", "w_vif",vif))
	`uvm_fatal(get_full_name(), "No virtual interface specified for write monitor");
    ap=new("ap",this);
  endfunction

  task run_phase(uvm_phase phase);
    @(posedge vif.wrst_n);
    //wait for reset
    forever begin
      tr = new();
      @(posedge vif.wclk);
      tr.wdata=vif.wdata;      
      @(negedge vif.wclk);      
      tr.winc=vif.winc;
      //uvm_report_info("write monitor","writes transaction,%d",tr.wdata);
      tr.wfull=vif.wfull;
      tr.almost_full=vif.almost_full;
      tr.waddr=vif.waddr;
      ap.write(tr);
    end
  endtask
endclass
`endif

