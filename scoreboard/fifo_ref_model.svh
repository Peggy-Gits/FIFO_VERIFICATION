`ifndef FIFO_REF_MODEL
`define FIFO_REF_MODEL
`uvm_analysis_imp_decl(_read)
`uvm_analysis_imp_decl(_write)
class fifo_ref_model extends uvm_component;
  `uvm_component_utils(fifo_ref_model)
  int ref_fifo[15:0]; 
  int rptr_1, rptr_2;
  int wptr_1, wptr_2;
  int wptr, rptr;
  bit full, empty;
  uvm_analysis_imp_read #(fifo_read_tr, fifo_ref_model)read_imp; 
  uvm_analysis_imp_write #(fifo_write_tr, fifo_ref_model)write_imp;
  function new(string name = "fifo_ref", uvm_component parent = null);
	super.new(name,parent);
  	read_imp=new("read_export", this);
	write_imp=new("write_export", this);
  endfunction
  function write_read(fifo_read_tr t);
    int expected;
    expected = ref_fifo[rptr%16];
    if (rptr == wptr_2) begin
	empty=1;
	rptr=rptr%16;
      `uvm_info("REF_MODEL", "empty", UVM_MEDIUM)
    end
    else begin
	empty=0;
	rptr=rptr+t.rinc;
    end

    if (expected !== t.rdata) begin
      `uvm_error("REF_MODEL", $sformatf("Mismatch! Expected: %0d, Got: %0d", expected, t.rdata))
    end
    else begin
      `uvm_info("REF_MODEL", $sformatf("Match! Value: %0d", t.rdata), UVM_MEDIUM)
    end
    wptr_2=wptr_1;
    wptr_1=wptr;
  endfunction
  function write_write(fifo_write_tr t);
	if((wptr+full*16)-rptr_2==16)begin
		full=1;
		wptr=wptr%16;
		`uvm_info("REF_MODEL", $sformatf("dropped data: %0d", t.wdata), UVM_MEDIUM)
	end
	else begin 
	full=0;
	if(t.winc==1)ref_fifo[wptr%16]=(t.wdata);
	`uvm_info("REF_MODEL", $sformatf("Pushed to model FIFO: %0d", t.wdata), UVM_MEDIUM)
	wptr=wptr+t.winc;
	end
	rptr_2=rptr_1;
	rptr_1=rptr;
  endfunction
endclass
`endif
