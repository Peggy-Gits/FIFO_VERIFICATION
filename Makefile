UVM_VERBOSITY = UVM_MEDIUM
TEST = tb_test
VCS =	$(VCS_HOME)/bin/vcs -full64 -sverilog -timescale=1ns/1ns \
	-debug_access+all\
	-kdb\
	-ntb_opts uvm \
	-cm line+cond+fsm+branch+tgl -cm_dir ./coverage.vdb -l comp.log 

SIMV = ./simv +UVM_VERBOSITY=$(UVM_VERBOSITY) \
	+UVM_TESTNAME=$(TEST) +UVM_TR_RECORD +UVM_LOG_RECORD \
	+verbose=1 +ntb_random_seed=244\
	-cm line+cond+fsm+branch+tgl -cm_dir ./coverage.vdb\
       	-l vcs.log

x:	comp run 

comp:
	$(VCS) +incdir+. -top testbench testbench.sv fifo.sv fifo_if.sv fifo_r_if.sv fifo_w_if.sv 

run:
	$(SIMV)

check_cov:
	$(VERDI_HOME)/bin/verdi -cov -covdir ./coverage.vdb
waves_verdi:
	$(VERDI_HOME)/bin/verdi -dbdir ./simv.daidir -ssf novas.fsdb -nologo

clean:
	rm -rf coverage.vdb csrc DVEfiles inter.vpd simv simv.daidir ucli.key vc_hdrs.h vcs.log .inter.vpd.uvm
