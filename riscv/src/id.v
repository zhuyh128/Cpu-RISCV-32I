`include "define.v"

module id(
	input rst,
    input clk,
	input wire[`StallBus]		stall,

	input wire[`RegBus]      	ifid_inst_in,
	input wire[`RegBus]  	    ifid_addr_in,

    input wire[`RegBus] reg1_data_in,
    input wire[`RegBus] reg2_data_in,
    output reg reg1_re,
    output reg reg2_re,
    output reg[`RegAddrBus] reg1_addr_out,
    output reg[`RegAddrBus] reg2_addr_out,

	output reg[`RegBus]			id_addr_out,
	output reg[`ExecBus]		id_exec_out,
	output reg[`RegBus]			id_rs1_out,
	output reg[`RegBus]			id_rs2_out,
	output reg[`RegBus]			id_imm_out,
	output reg[`RegAddrBus]		id_rdest_out,
	output reg 					id_we_out,	
	output reg 					id_mux_out,

	output reg 					id_data_stall,

	output reg[`RegBus]			id_new_addr_out,
	output reg 					branch_flag,

	input wire 					ex_we_in,
	input wire[`RegAddrBus] 	ex_addr_in,
	input wire[`RegBus]			ex_data_in,
	input wire[`ExecBus] 		ex_exec_in,

	input wire 					mem_we_in,
	input wire[`RegAddrBus] 	mem_addr_in,
	input wire[`RegBus] 		mem_data_in
);

integer i;

reg 				id_data1_stall;
reg 				id_data2_stall;

always @(*) begin
	if(rst) begin
		id_rs1_out		<= 0;
		id_data1_stall	<= 0;
	end else begin
		if(reg1_re) begin
			if(ex_we_in && ex_addr_in == rs1) begin
				if((
					ex_exec_in == `EXE_LB_OP || 
					ex_exec_in == `EXE_LH_OP ||  
					ex_exec_in == `EXE_LW_OP ||  
					ex_exec_in == `EXE_LBU_OP||  
					ex_exec_in == `EXE_LHU_OP)) begin
					id_data1_stall	<= 1;
					id_rs1_out		<= 0;
				end else begin
					id_data1_stall	<= 0;
					id_rs1_out		<= ex_data_in;
				end
			end else if(mem_we_in && mem_addr_in == rs1) begin
				id_data1_stall	<= 0;
				id_rs1_out		<= ex_data_in;
			end 
            else begin
				id_data1_stall	<= 0;
                reg1_addr_out <= rs1;
                id_rs1_out <= reg1_data_in;
			end
		end else begin
			id_rs1_out		<= 0;
			id_data1_stall	<= 0;
		end
	end
end

always @(*) begin
	if(rst) begin
		id_rs2_out		<= 0;
		id_data2_stall	<= 0;
	end else begin
		if(reg2_re) begin
			if(ex_we_in && ex_addr_in == rs2) begin
				if((
					ex_exec_in == `EXE_LB_OP || 
					ex_exec_in == `EXE_LH_OP ||  
					ex_exec_in == `EXE_LW_OP ||  
					ex_exec_in == `EXE_LBU_OP||  
					ex_exec_in == `EXE_LHU_OP)) begin
					id_data2_stall	<= 1;
					id_rs2_out		<= 0;
				end else begin
					id_data2_stall	<= 0;
					id_rs2_out		<= ex_data_in;
				end
			end else if(mem_we_in && mem_addr_in == rs2) begin
				id_data2_stall	<= 0;
				id_rs2_out		<= ex_data_in;
			end 
            else begin
				id_data2_stall	<= 0;
                reg2_addr_out <= rs2;
                id_rs2_out <= reg2_data_in;
			end
		end else begin
			id_rs2_out		<= 0;
			id_data2_stall	<= 0;
		end
	end
end

always @(*) begin
	if(rst) begin
		id_data_stall	<= 0;
	end else  begin
		id_data_stall  	<= (id_data1_stall || id_data2_stall);
	end
end

wire[`OpCodeBus]  	opCode;
wire[2:0]  	funct3;
wire[6:0]  	funct7;
wire[`RegAddrBus] 	rd, rs1, rs2;
wire[`RegBus]  		imm, jmm, smm, bmm, umm;

assign opCode  = ifid_inst_in[`Opcode_Interval];
assign rd = ifid_inst_in[`Rd_Interval];
assign funct7  = ifid_inst_in[`Func7_Interval];
assign funct3  = ifid_inst_in[`Func3_Interval];
assign rs1 = ifid_inst_in[`Rs1_Interval];
assign rs2 = ifid_inst_in[`Rs2_Interval];

assign imm    = {{20{ifid_inst_in[31]}}, ifid_inst_in[`Imm_Interval]};
assign jmm    = {{12{ifid_inst_in[31]}}, ifid_inst_in[19:12], ifid_inst_in[20],ifid_inst_in[30:21],1'h0};
assign smm    = {{20{ifid_inst_in[31]}}, ifid_inst_in[31:25], ifid_inst_in[11:7]};
assign bmm    = {{20{ifid_inst_in[31]}}, ifid_inst_in[7], ifid_inst_in[30:25], ifid_inst_in[11:8], 1'h0};
assign umm    = {ifid_inst_in[`Jmm_Interval], 12'h000};

always @(*) begin
	if(rst) begin
	    id_exec_out  	<= 0;
		id_imm_out      <= 0;
		id_rdest_out 	<= 0;
		id_we_out       <= 0;
		id_mux_out      <= 0;
		id_new_addr_out	<= `max32;
		id_addr_out 	<= 0;
		reg1_re			<= 0;
		reg2_re 		<= 0;
		branch_flag		<= 0;
	end else begin
		case(opCode)
			`Op_Imm :begin
				reg1_re				<= 1;
				reg2_re				<= 0;
				id_mux_out			<= 1;
				id_rdest_out 		<= rd;
				id_we_out			<= 1;
				id_new_addr_out		<= `max32;
				id_addr_out 		<= 0;
				branch_flag			<= 0;
				case(funct3) 
					`FUNCT3_ADDI: begin
						id_exec_out			<= `EXE_ADD_OP;
						id_imm_out			<= imm;
					end
					`FUNCT3_SLTI: begin
						id_exec_out			<= `EXE_SLT_OP;
						id_imm_out			<= imm;
					end
					`FUNCT3_SLTIU: begin
						id_exec_out			<= `EXE_SLTU_OP;
						id_imm_out			<= imm;
					end
					`FUNCT3_ANDI: begin
						id_exec_out			<= `EXE_AND_OP;
						id_imm_out			<= {20'h0,imm[11:0]};
					end
					`FUNCT3_ORI:  begin
						id_exec_out			<= `EXE_OR_OP;
						id_imm_out			<= {20'h0,imm[11:0]};
					end
					`FUNCT3_XORI:  begin
						id_exec_out			<= `EXE_XOR_OP;
						id_imm_out			<= {20'h0,imm[11:0]};
					end
					`FUNCT3_SLLI: begin
						id_exec_out			<= `EXE_SLL_OP;
						id_imm_out			<= {27'h0,imm[4:0]};
					end
					`FUNCT3_SRLI: begin
						case(funct7)
							`FUNCT7_SRAI : begin
								id_exec_out			<= `EXE_SRA_OP;
								id_imm_out			<= {27'h0,imm[4:0]};
							end
							`FUNCT7_SRLI : begin
								id_exec_out			<= `EXE_SRL_OP;
								id_imm_out			<= {27'h0,imm[4:0]};
							end
							default      :begin
							    id_exec_out  	<= 0;
								reg1_re			<= 1;
								reg2_re			<= 0;
								id_imm_out      <= 0;
								id_rdest_out 	<= 0;
								id_we_out       <= 0;
								id_mux_out      <= 0;
								id_new_addr_out	<= `max32;
								id_addr_out 	<= 0;
								branch_flag		<= 0;
							end
						endcase
					end
					default     :begin
					    id_exec_out  	<= 0;
						reg1_re			<= 1;
						reg2_re			<= 0;
						id_imm_out      <= 0;
						id_rdest_out 	<= 0;
						id_we_out       <= 0;
						id_mux_out      <= 0;
						id_new_addr_out	<= `max32;
						id_addr_out 	<= 0;
						branch_flag		<= 0;
					end
				endcase
			end
			`Op_     :begin
				id_imm_out			<= 0;
				reg1_re				<= 1;
				reg2_re				<= 1;
				id_mux_out			<= 0;
				id_rdest_out 		<= rd;
				id_we_out			<= 1;
				id_new_addr_out		<= `max32;
				id_addr_out 		<= 0; 
				branch_flag			<= 0;
				case(funct3)
					`FUNCT3_ADD : begin
						case(funct7)
						`FUNCT7_ADD : begin
							id_exec_out			<= `EXE_ADD_OP;
						end
						`FUNCT7_SUB : begin
							id_exec_out			<= `EXE_SUB_OP;
						end
						default      :begin
						    id_exec_out  	<= 0;
							reg1_re			<= 0;
							reg2_re			<= 0;
							id_imm_out      <= 0;
							id_rdest_out 	<= 0;
							id_we_out       <= 0;
							id_mux_out      <= 0;
							id_new_addr_out	<= `max32;
							id_addr_out 	<= 0;
							branch_flag		<= 0;
						end
					endcase
					end
					`FUNCT3_SLL : begin
						id_exec_out			<= `EXE_SLL_OP;
					end
					`FUNCT3_SLT : begin
						id_exec_out			<= `EXE_SLT_OP;
					end
					`FUNCT3_SLTU: begin
						id_exec_out			<= `EXE_SLTU_OP;
					end
					`FUNCT3_XOR: begin
						id_exec_out			<= `EXE_XOR_OP;
					end
					`FUNCT3_SRA: begin
						case(funct7)
							`FUNCT7_SRA: begin
								id_exec_out			<= `EXE_SRA_OP;
							end
							`FUNCT7_SRL: begin
								id_exec_out			<= `EXE_SRL_OP;
							end
							default      :begin
							    id_exec_out  	<= 0;
								reg1_re			<= 0;
								reg2_re			<= 0;
								id_imm_out      <= 0;
								id_rdest_out 	<= 0;
								id_we_out       <= 0;
								id_mux_out      <= 0;
								id_new_addr_out	<= `max32;
								id_addr_out 	<= 0;
								branch_flag		<= 0;
							end
						endcase
					end
					`FUNCT3_OR: begin
						id_exec_out			<= `EXE_OR_OP;
					end
					`FUNCT3_AND: begin
						id_exec_out			<= `EXE_AND_OP;
					end
					default      :begin
					    id_exec_out  	<= 0;
						reg1_re			<= 0;
						reg2_re			<= 0;
						id_imm_out      <= 0;
						id_rdest_out 	<= 0;
						id_we_out       <= 0;
						id_mux_out      <= 0;
						id_new_addr_out	<= `max32;
						id_addr_out 	<= 0;
						branch_flag		<= 0;
					end
				endcase
			end
			`LUI_    :begin
				id_exec_out			<= `EXE_LUI_OP;
				id_imm_out			<= umm;
				reg1_re				<= 0;
				reg2_re				<= 0;	
				id_mux_out			<= 0;
				id_rdest_out 		<= rd;
				id_we_out			<= 1;
				id_new_addr_out		<= `max32;
				id_addr_out 		<= 0;
				branch_flag			<= 0;
			end
			`AUIPC_  :begin
				id_exec_out			<= `EXE_AUIPC_OP;
				id_imm_out			<= umm;
				reg1_re				<= 0;
				reg2_re				<= 0;
				id_mux_out			<= 1; 
				id_rdest_out 		<= rd;
				id_we_out			<= 1;
				id_new_addr_out		<= `max32;
				id_addr_out 		<= ifid_addr_in;
				branch_flag			<= 0;
			end
			`JAL_    :begin
				id_exec_out			<= `EXE_JAL_OP;
				id_imm_out			<=	32'b0100;
				reg1_re				<= 0;
				reg2_re				<= 0;
				id_mux_out			<= 1;
				id_rdest_out		<= rd;
				id_we_out			<= 1;
				id_new_addr_out		<= ifid_addr_in + jmm;
				id_addr_out 		<= ifid_addr_in;
				branch_flag			<= 1;
			end
			`JALR_   :begin
				id_exec_out			<= `EXE_JALR_OP;
				id_imm_out			<= 32'b0100;
				reg1_re				<= 1;
				reg2_re				<= 0;
				id_mux_out			<= 1;
				id_rdest_out		<= rd;
				id_we_out			<= 1;
				id_new_addr_out		<= id_rs1_out + imm;
				id_addr_out 		<= ifid_addr_in;
				branch_flag			<= 1;
			end
			`BRANCH_ :begin
				id_exec_out			<= `EXE_BLT_OP;
				reg1_re				<= 1;
				reg2_re				<= 1;
				id_imm_out			<= 0;
				id_mux_out			<= 0;
				id_rdest_out		<= 0;
				id_we_out			<= 0;
				id_addr_out 		<= 0;
				case(funct3)
					`FUNCT3_BLT : begin
						id_new_addr_out	<= ($signed(id_rs1_out) < $signed(id_rs2_out)) ? ifid_addr_in + bmm : ifid_addr_in + 4;
					end
					`FUNCT3_BGE	: begin
						id_new_addr_out	<= ($signed(id_rs1_out) >= $signed(id_rs2_out)) ? ifid_addr_in + bmm : ifid_addr_in + 4;
					end
					`FUNCT3_BNE	: begin
						id_new_addr_out	<= id_rs1_out != id_rs2_out ? ifid_addr_in + bmm : ifid_addr_in + 4;
					end
					`FUNCT3_BEQ	: begin
						id_new_addr_out	<= id_rs1_out == id_rs2_out ? ifid_addr_in + bmm : ifid_addr_in + 4;
					end
					`FUNCT3_BLTU: begin
						id_new_addr_out	<= (id_rs1_out < id_rs2_out) ? ifid_addr_in + bmm : ifid_addr_in + 4;
					end
					`FUNCT3_BGEU: begin
						id_new_addr_out	<= (id_rs1_out >= id_rs2_out) ? ifid_addr_in + bmm : ifid_addr_in + 4;
					end
				endcase
				branch_flag			<= 1;
			end
			`Store_   :begin
				id_imm_out			<= smm;
				reg1_re				<= 1;
				reg2_re				<= 1;
				id_mux_out			<= 1;
				id_rdest_out 		<= 0;
				id_we_out			<= 0;
				id_new_addr_out		<= `max32;
				id_addr_out 		<= ifid_addr_in;
				case(funct3)
					`FUNCT3_SW : begin
						id_exec_out			<= `EXE_SW_OP;
					end
					`FUNCT3_SH : begin
						id_exec_out			<= `EXE_SH_OP;
					end
					`FUNCT3_SB : begin
						id_exec_out			<= `EXE_SB_OP;
					end
				endcase
				branch_flag			<= 0;
			end
			`Load_   :begin

					case(funct3)
						`FUNCT3_LW : begin
							id_exec_out			<= `EXE_LW_OP;
						end
						`FUNCT3_LH : begin
							id_exec_out			<= `EXE_LH_OP;
						end
						`FUNCT3_LB : begin
							id_exec_out			<= `EXE_LB_OP;
						end
						`FUNCT3_LBU : begin
							id_exec_out			<= `EXE_LBU_OP;
						end
						`FUNCT3_LHU : begin
							id_exec_out			<= `EXE_LHU_OP;
						end
					endcase
					id_imm_out			<= imm;
					reg1_re				<= 1;
					reg2_re 			<= 0;
					id_mux_out			<= 1;
					id_rdest_out 		<= rd;
					id_we_out			<= 1;
					id_new_addr_out		<= `max32;
					id_addr_out 		<= ifid_addr_in;
					branch_flag			<= 0;
			end
			
			default      :begin
			    id_exec_out  	<= 0;
				reg1_re			<= 0;
				reg2_re 		<= 0;
				id_imm_out      <= 0;
				id_rdest_out 	<= 0;
				id_we_out       <= 0;
				id_mux_out      <= 0;
				id_new_addr_out	<= 0;
				id_addr_out 	<= 0;
				branch_flag		<= 0;
			end
		endcase
	end
end

endmodule