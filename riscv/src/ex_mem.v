`include "define.v"
module ex_mem(
	input wire				rst,
	input wire				clk,
	input wire[`StallBus] 	stall,
	input wire[`RegBus]		ex_alu_in,
	input wire[`RegBus]		ex_rs1_in,
	input wire[`RegBus]		ex_rs2_in,
	input wire[`ExecBus]	ex_exec_in,
	input wire[`RegAddrBus]	ex_rdest_in,
	input wire				ex_we_in,

	output reg[`RegBus]		exmem_alu_out,
	output reg[`RegBus]		exmem_rs1_out,
	output reg[`RegBus]		exmem_rs2_out,
	output reg[`ExecBus]	exmem_exec_out,
	output reg[`RegAddrBus]	exmem_rdest_out,
	output reg 				exmem_we_out
);

always @(posedge clk) begin
	if(rst || (stall[3] && !stall[4])) begin
		exmem_alu_out	<= 0;
		exmem_rs1_out	<= 0;
		exmem_rs2_out	<= 0;
		exmem_exec_out	<= 0;
		exmem_rdest_out	<= 0;
		exmem_we_out	<= 0;
	end	else if(!stall[3]) begin
		exmem_alu_out	<= ex_alu_in;
		exmem_rs1_out	<= ex_rs1_in;
		exmem_rs2_out	<= ex_rs2_in;
		exmem_exec_out	<= ex_exec_in;
		exmem_rdest_out	<= ex_rdest_in;
		exmem_we_out	<= ex_we_in;
	end
end
endmodule
