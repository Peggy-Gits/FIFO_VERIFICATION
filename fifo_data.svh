`ifndef FIFO_DATA
`define FIFO_DATA
`define MEM_SIZE 1024
class fifo_data;
	int mem[`MEM_SIZE-1:0];
	int write_length=16;
	extern function new(string file_name);
endclass
function fifo_data::new(string file_name);
	$readmemh(file_name,mem);
endfunction

`endif
