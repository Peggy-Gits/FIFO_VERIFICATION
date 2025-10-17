`define FIFO_DEPTH 16
`define DSIZE 8
`define ASIZE 4
`ifndef IDEAL_FIFO
`define IDEAL_FIFO
class ideal_fifo;
   int fifo[0:`FIFO_DEPTH-1];
   bit[`ASIZE:0] rptr;
   bit[`ASIZE:0] wptr;
   function int write(int data);
	//fifo.push_back(data);
	fifo[wptr]=data;
	wptr++;
	uvm_report_info("IDEAL_FIFO",$psprintf("%d,fifo:%d",wptr,data));
	return wptr;
   endfunction
   function int read();
	int read=fifo[rptr];
	//fifo.pop_front();
	rptr++;
	return read;
   endfunction
   function bit is_empty();
	return rptr==wptr;
   endfunction
   function bit is_full();
	return wptr[`ASIZE]&(!rptr[`ASIZE]);
   endfunction
endclass
`endif
