class fifo_tr extends uvm_transaction; 
   bit [`DSIZE-1:0] rdata, wdata;
   bit wfull, almost_full;
   bit rempty, almost_empty;
   bit winc, rinc;
   function string get_content();
	return $psprintf("\n \
-------------------------FIFO_TRANSFER------------------------- \n \
READ=%b \n \
RDATA=%0h \n \
WRITE=%b \n \
WDATA=%0h\n\
--------------------------------------------------------------",rinc,rdata,winc,wdata);
   endfunction
endclass
