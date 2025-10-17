`ifndef COVERAGE_COLLECTOR
`define COVERAGE_COLLECTOR
class coverage_collector extends uvm_component;
  `uvm_component_utils(coverage_collector)
 
  //instruction tr;
  uvm_analysis_imp #(fifo_tr, coverage_collector) imp;
  //uvm_analusis_imp #(fifo_tr, coverage_collector) w_imp;
  fifo_tr r_tr;//r_tr, w_tr; 
  covergroup read_cg;
    coverpoint r_tr.rempty;
    coverpoint r_tr.almost_empty;
    coverpoint r_tr.rinc{
	bins read_when_write[]={0,1}iff (r_tr.winc==1);
	bins read_not_write[] ={0,1}iff (r_tr.winc==0);
	bins empty_read[]     ={0,1}iff (r_tr.rempty==1);
        bins full_read[]      ={0,1}iff (r_tr.wfull==1);
    }
  endgroup: read_cg;
  covergroup write_cg;
    coverpoint r_tr.wfull;
    coverpoint r_tr.almost_full;
    coverpoint r_tr.winc{
        bins write_when_read[]={0,1}iff (r_tr.rinc==1);
	bins write_not_read[] ={0,1}iff (r_tr.rinc==0);
	bins empty_write[]    ={0,1}iff (r_tr.rempty==1);
        bins full_write[]     ={0,1}iff (r_tr.wfull==1);
    }
  endgroup
  function new(string name, uvm_component parent);
    super.new(name, parent);
    read_cg = new;
    write_cg= new;
  endfunction

  function void build_phase(uvm_phase phase);
    imp=new("imp",this);
    //w_imp=new("w_imp",this);
  endfunction

  function void write(fifo_tr t);
    r_tr=t;
    read_cg.sample();
    write_cg.sample();
  endfunction
endclass
`endif
