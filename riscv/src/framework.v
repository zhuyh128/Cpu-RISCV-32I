`include "define.v"
module framework(
	input wire 				clk,
	input wire 				rst,
	input wire 				rdy,
	input wire[31:0]	mem_din,
	output wire[31:0]	mem_a,
	output wire[7:0]	mem_dout,
	output wire				mem_wr
);


wire reg1_re;
wire[`RegAddrBus] reg1_addr;
wire[`RegBus] reg1_data;

wire reg2_re;
wire[`RegAddrBus] reg2_addr;
wire[`RegBus] reg2_data;


wire[`StallBus]	stall;
wire 			ctrl_if_stall_stall;
wire 			id_data_stall_stall;
wire 			mem_ma_stall_stall;
wire 			if_b_stall_stall;

wire[`RegBus] 		if_addr_ctrl;
wire 				if_ce_ctrl;
wire 				id_br_if;

wire[`RegBus]		if_inst_ifid;
wire[`RegBus] 		if_addr_ifid;
wire[`RegBus]		id_new_addr_if;

wire[`RegBus]	ifid_addr_id;
wire[`RegBus]	ifid_inst_id;

wire[`ExecBus]		id_exec_idex;
wire[`RegBus]		id_rs1_idex;
wire[`RegBus]		id_rs2_idex;
wire[`RegBus]		id_imm_idex;
wire[`RegBus]		id_addr_idex;
wire[`RegAddrBus]	id_rdest_idex;
wire				id_we_idex;
wire				id_mux_idex;	

wire[`RegBus]		memwb_res_reg;
wire[`RegAddrBus]	memwb_rdest_reg;
wire				memwb_we_reg;

wire				ex_fw_we_id;
wire[`RegAddrBus]	ex_fw_addr_id;
wire[`RegBus]		ex_fw_data_id;
wire[`ExecBus]		ex_fw_exec_id;

wire				mem_fw_we_id;
wire[`RegAddrBus]	mem_fw_addr_id;
wire[`RegBus]		mem_fw_data_id;

stall stall0(
				.rst(rst),
				.rdy(rdy),
				.stall(stall),
				.if_mem_stall_in(ctrl_if_stall_stall),
				.id_data_stall_in(id_data_stall_stall),
				.mem_ma_stall_in(mem_ma_stall_stall),
				.if_b_stall_in(if_b_stall_stall)
			);

ifetch 		ifetch0(	.clk(clk),
				.rst(rst),
				.br_flag(id_br_if),
				.stall(stall),
				.new_addr(id_new_addr_if),
				.mem_data_in(mem_din),

				.if_inst_out(if_inst_ifid),
				.if_addr_out(if_addr_ifid),

				.if_ctrl_addr(if_addr_ctrl),
				.ctrl_ce(if_ce_ctrl),
				.if_b_stall_req(if_b_stall_stall)
			);


if_id 	if_id0(	.clk(clk),
				.rst(rst),
				.stall(stall),
				.if_inst_in(if_inst_ifid),
				.if_addr_in(if_addr_ifid),
				.id_addr_out(ifid_addr_id),
				.id_inst_out(ifid_inst_id)
			);


reg_file reg_file0(
	.rst(rst),
	.clk(clk),

	.we(memwb_we_reg),
	.w_addr(memwb_rdest_reg),
	.w_data(memwb_res_reg),

	.re_a(reg1_re),
	.r_addr_a(reg1_addr),
	.r_data_a(reg1_data),

	.re_b(reg2_re),
	.r_addr_b(reg2_addr),
	.r_data_b(reg2_data)
);

id 		id0(	.rst(rst),
				.clk(clk),
				.stall(stall),

				.ifid_inst_in(ifid_inst_id),
				.ifid_addr_in(ifid_addr_id),

				// .reg_we(memwb_we_reg),
				// .reg_addr(memwb_rdest_reg),
				// .reg_data(memwb_res_reg),
				.reg1_re(reg1_re),
				.reg1_addr_out(reg1_addr),
				.reg1_data_in(reg1_data),

				.reg2_re(reg2_re),
				.reg2_addr_out(reg2_addr),
				.reg2_data_in(reg2_data),

				.id_exec_out(id_exec_idex),
				.id_rs1_out(id_rs1_idex),
				.id_rs2_out(id_rs2_idex),
				.id_imm_out(id_imm_idex),
				.id_addr_out(id_addr_idex),
				.id_rdest_out(id_rdest_idex),
				.id_we_out(id_we_idex),
				.id_mux_out(id_mux_idex),

				.id_data_stall(id_data_stall_stall),
				.id_new_addr_out(id_new_addr_if),
				.branch_flag(id_br_if),

				.ex_we_in(ex_fw_we_id),
				.ex_addr_in(ex_fw_addr_id),
				.ex_data_in(ex_fw_data_id),
				.ex_exec_in(ex_fw_exec_id),

				.mem_we_in(mem_fw_we_id),
				.mem_addr_in(mem_fw_addr_id),
				.mem_data_in(mem_fw_data_id)
			);

wire[`ExecBus]		idex_exec_ex;
wire[`RegAddrBus]	idex_rdest_ex;
wire[`RegBus]		idex_rs1_ex;
wire[`RegBus]		idex_rs2_ex;
wire[`RegBus]		idex_imm_ex;
wire[`RegBus]		idex_addr_ex;
wire				idex_mux_ex;
wire				idex_we_ex;

id_ex 	id_ex0(
				.rst(rst),
				.clk(clk),
				.stall(stall),

				.id_exec_in(id_exec_idex),
				.id_rdest_in(id_rdest_idex),
				.id_rs1_in(id_rs1_idex),
				.id_rs2_in(id_rs2_idex),
				.id_imm_in(id_imm_idex),
				.id_addr_in(id_addr_idex),
				.id_we_in(id_we_idex),
				.id_mux_in(id_mux_idex),

				.idex_exec_out(idex_exec_ex),
				.idex_rdest_out(idex_rdest_ex),
				.idex_rs1_out(idex_rs1_ex),
				.idex_rs2_out(idex_rs2_ex),
				.idex_imm_out(idex_imm_ex),
				.idex_addr_out(idex_addr_ex),
				.idex_mux_out(idex_mux_ex),
				.idex_we_out(idex_we_ex)
			);

wire[`RegBus]		ex_alu_exmem;
wire[`RegBus]		ex_rs1_exmem;
wire[`RegBus]		ex_rs2_exmem;
wire[`ExecBus]		ex_exec_exmem;
wire[`RegAddrBus]	ex_rdest_exmem;
wire				ex_we_exmem;

ex 		ex0(
				.rst(rst),
				.clk(clk),
				.stall(stall),

				.idex_exec_in(idex_exec_ex),
				.idex_rdest_in(idex_rdest_ex),
				.idex_rs1_in(idex_rs1_ex),
				.idex_rs2_in(idex_rs2_ex),
				.idex_imm_in(idex_imm_ex),
				.idex_addr_in(idex_addr_ex),
				.idex_mux_in(idex_mux_ex),
				.idex_we_in(idex_we_ex),

				.ex_alu_out(ex_alu_exmem),
				.ex_rs1_out(ex_rs1_exmem),
				.ex_rs2_out(ex_rs2_exmem),
				.ex_exec_out(ex_exec_exmem),
				.ex_rdest_out(ex_rdest_exmem),
				.ex_we_out(ex_we_exmem)
			);

wire[`RegBus]		exmem_alu_mem;
wire[`RegBus]		exmem_rs1_mem;
wire[`RegBus]		exmem_rs2_mem;
wire[`ExecBus]		exmem_exec_mem;
wire[`RegAddrBus]	exmem_rdest_mem;
wire				exmem_we_mem;

assign ex_fw_data_id 	= ex_alu_exmem;
assign ex_fw_addr_id 	= ex_rdest_exmem ;
assign ex_fw_we_id 		= ex_we_exmem;
assign ex_fw_exec_id	= ex_exec_exmem;

ex_mem	ex_mem0(
				.rst(rst),
				.clk(clk),
				.stall(stall),

				.ex_alu_in(ex_alu_exmem),
				.ex_rs1_in(ex_rs1_exmem),
				.ex_rs2_in(ex_rs2_exmem),
				.ex_exec_in(ex_exec_exmem),
				.ex_rdest_in(ex_rdest_exmem),
				.ex_we_in(ex_we_exmem),

				.exmem_alu_out(exmem_alu_mem),
				.exmem_rs1_out(exmem_rs1_mem),
				.exmem_rs2_out(exmem_rs2_mem),
				.exmem_exec_out(exmem_exec_mem),
				.exmem_rdest_out(exmem_rdest_mem),
				.exmem_we_out(exmem_we_mem)
			);

wire[`RegBus]		mem_res_memwb;
wire[`RegAddrBus]	mem_rdest_memwb;
wire        		mem_we_memwb;

wire[`RegBus]		ctrl_data_mem;
wire 				ctrl_busy_mem;

wire[`RegBus]		mem_addr_ctrl;
wire[`ByteBus]		mem_data_ctrl;
wire[`MemDataType]	mem_type_ctrl;
wire 				mem_rw_ctrl;
wire 				mem_ce_ctrl;

mem		mem0(
				.rst(rst),
				.clk(clk),

				.exmem_alu_in(exmem_alu_mem),
				.exmem_rs1_in(exmem_rs1_mem),
				.exmem_rs2_in(exmem_rs2_mem),
				.exmem_exec_in(exmem_exec_mem),
				.exmem_rdest_in(exmem_rdest_mem),
				.exmem_we_in(exmem_we_mem),

				.ma_data_in(mem_din),

				.mem_res_out(mem_res_memwb),
				.mem_rdest_out(mem_rdest_memwb),
				.mem_we_out(mem_we_memwb),

				.ma_addr_out(mem_addr_ctrl),
				.ma_data_out(mem_data_ctrl),
				.ma_rw_flag(mem_rw_ctrl),
				.ma_ce_flag(mem_ce_ctrl)
			);


assign mem_fw_data_id = mem_res_memwb;
assign mem_fw_addr_id = mem_rdest_memwb;
assign mem_fw_we_id   = mem_we_memwb;

mem_wb 	mem_wb0(
				.rst(rst),
				.clk(clk),
				.stall(stall),
				.exmem_res_in(mem_res_memwb),
				.exmem_rdest_in(mem_rdest_memwb),
				.exmem_we_in(mem_we_memwb),

				.memwb_res_out(memwb_res_reg),
				.memwb_rdest_out(memwb_rdest_reg),
				.memwb_we_out(memwb_we_reg)
			);

control control0(
				.rst(rst),
				.rdy(rdy),
				
				.inst_ce(if_ce_ctrl),
				.if_inst_addr_in(if_addr_ctrl),

				.data_ce(mem_ce_ctrl),
				.mem_data_in(mem_data_ctrl),
				.mem_data_addr_in(mem_addr_ctrl),
				.mem_rw_in(mem_rw_ctrl),

				.ma_addr_out(mem_a),
				.ma_data_out(mem_dout),
				.ma_rw_out(mem_wr),

				.if_ma_stall(ctrl_if_stall_stall),
				.mem_ma_stall(mem_ma_stall_stall)
		);

endmodule