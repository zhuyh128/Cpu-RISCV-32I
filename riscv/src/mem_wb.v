`include "define.v"
module mem_wb(
	input wire 					rst,
	input wire 					clk,
	input wire[`StallBus]     	stall,
	input wire[`RegBus]			exmem_res_in,
	input wire[`RegAddrBus]		exmem_rdest_in,
	input wire					exmem_we_in,

	output reg[`RegBus]			memwb_res_out,
	output reg[`RegAddrBus]		memwb_rdest_out,
	output reg 					memwb_we_out
);

always @(posedge clk) begin
	if((stall[4] && !stall[5]) || rst) begin
		memwb_we_out	<= 0;
		memwb_rdest_out	<= 0;
		memwb_res_out	<= 0;
	end else if(!stall[4])begin
		memwb_res_out	<= exmem_res_in;
		memwb_rdest_out	<= exmem_rdest_in;
		memwb_we_out	<= exmem_we_in;
	end
end
endmodule