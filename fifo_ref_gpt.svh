class fifo_ref_model extends uvm_component;
  `uvm_component_utils(fifo_ref_model)

  // Internal queue to store int values
  protected int ref_fifo[$];

  // Analysis exports to receive transactions from monitors
  uvm_analysis_export #(fifo_w_tr) wr_export;
  uvm_analysis_export #(fifo_r_tr) rd_export;

  function new(string name = "fifo_ref_model", uvm_component parent = null);
    super.new(name, parent);
    wr_export = new("wr_export", this);
    rd_export = new("rd_export", this);
  endfunction

  // Called when DUT performs a write
  virtual function void write(fifo_w_tr t);
    ref_fifo.push_back(t.value);
    `uvm_info("REF_MODEL", $sformatf("Pushed to model FIFO: %0d", t.value), UVM_MEDIUM)
  endfunction

  // Called when DUT performs a read
  virtual function void read(fifo_r_tr t);
    int expected;

    if (ref_fifo.size() == 0) begin
      `uvm_error("REF_MODEL", "Attempted to read from empty reference FIFO!")
      return;
    end

    expected = ref_fifo.pop_front();

    if (expected !== t.value) begin
      `uvm_error("REF_MODEL", $sformatf("Mismatch! Expected: %0d, Got: %0d", expected, t.value))
    end
    else begin
      `uvm_info("REF_MODEL", $sformatf("Match! Value: %0d", t.value), UVM_MEDIUM)
    end
  endfunction
endclass