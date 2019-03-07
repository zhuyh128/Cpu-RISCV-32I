`include "define.v"
module id_ex(
	input rst,
	input clk,

	input wire[`StallBus]	stall,
	
	input wire[`ExecBus]	id_exec_in,
	input wire[`RegAddrBus]	id_rdest_in,
	input wire[`RegBus]		id_rs1_in,
	input wire[`RegBus]		id_rs2_in,
	input wire[`RegBus]		id_imm_in,
	input wire[`RegBus]		id_addr_in,
	input wire 				id_we_in,
	input wire				id_mux_in,

	output reg[`ExecBus]	idex_exec_out,
	output reg[`RegAddrBus]	idex_rdest_out,
	output reg[`RegBus]		idex_rs1_out,
	output reg[`RegBus]		idex_rs2_out,
	output reg[`RegBus]		idex_imm_out,
	output reg[`RegBus]		idex_addr_out,
	output reg				idex_mux_out,
	output reg 				idex_we_out
);

always @(posedge clk) begin
	if(rst || (stall[2] && !stall[3])) begin
		idex_exec_out	<= 0;
		idex_rs2_out 	<= 0;
		idex_rs1_out 	<= 0;
		idex_imm_out	<= 0;
		idex_addr_out	<= 0;
		idex_mux_out	<= 0;
		idex_rdest_out	<= 0;
		idex_we_out		<= 0;
	end else if(!stall[2]) begin
		idex_exec_out 	<= id_exec_in;
		idex_mux_out	<= id_mux_in;
		idex_rs1_out 	<= id_rs1_in;
		idex_rs2_out 	<= id_rs2_in;
		idex_imm_out	<= id_imm_in;
		idex_addr_out	<= id_addr_in;
		idex_rdest_out	<= id_rdest_in;
		idex_we_out		<= id_we_in;
	end
end

endmodule