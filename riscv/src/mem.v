`include "define.v"
module mem(
	input wire					rst,
	input wire					clk,

	input wire[`RegBus]			exmem_alu_in,
	input wire[`RegBus]			exmem_rs1_in,
	input wire[`RegBus]			exmem_rs2_in,
	input wire[`ExecBus]		exmem_exec_in,
	input wire[`RegAddrBus]		exmem_rdest_in,
	input wire					exmem_we_in,

	input wire[`ByteBus]		ma_data_in,

	output reg[`RegBus]			mem_res_out,
	output reg[`RegAddrBus]		mem_rdest_out,
	output reg					mem_we_out,

	output reg[`RegBus]			ma_addr_out,
	output reg[`ByteBus]		ma_data_out,
	output reg 					ma_rw_flag,
	output reg 					ma_ce_flag
);

reg 			ma_done;
reg[3:0] 		stage;
reg[`RegBus] 	ma_res;

always @(posedge clk) begin
	if(rst) begin
		stage		<= 0;
		ma_res		<= 0;
		ma_done 	<= 0;
		ma_addr_out	<= 0;
		ma_data_out	<= 0;
		ma_rw_flag	<= 0;
	end else if(ma_ce_flag) begin
		case(stage)
			0:begin
				ma_addr_out <= exmem_alu_in;
				ma_done		<= 0;
				case(exmem_exec_in)
					`EXE_SW_OP,`EXE_SH_OP,`EXE_SB_OP:begin
						ma_rw_flag	<= 1;
						ma_data_out	<= exmem_rs2_in[7:0];
						stage 		<= 1;
					end
					`EXE_LW_OP,`EXE_LH_OP,`EXE_LB_OP,`EXE_LBU_OP,`EXE_LHU_OP:begin
						ma_rw_flag	<= 0;
						stage 		<= 1;
					end
				endcase
			end
			1:begin
				case(exmem_exec_in)
					`EXE_SB_OP:begin
						ma_rw_flag	<= 0;
						ma_done		<= 1;
						stage 		<= 0;
						ma_addr_out	<= 0;
					end
					`EXE_SH_OP,`EXE_SW_OP:begin
						ma_data_out	<= exmem_rs2_in[15:8];
						ma_addr_out	<= exmem_alu_in + 1;
						stage 		<= 2;
					end
					default:begin
						stage 		<= 2;
					end
				endcase
			end
			2:begin
				case(exmem_exec_in)
					`EXE_SH_OP:begin
						ma_rw_flag	<= 0;
						ma_done		<= 1;
						stage 		<= 0;
						ma_addr_out	<= 0;
					end
					`EXE_SW_OP:begin
						ma_data_out	<= exmem_rs2_in[23:16];
						ma_addr_out	<= exmem_alu_in + 2;
						stage 		<= 3;
					end
					`EXE_LB_OP:begin
						ma_res		<= {{24{ma_data_in[7]}}, ma_data_in};
						ma_done		<= 1;
						stage 		<= 0;
						ma_addr_out	<= 0;
					end
					`EXE_LBU_OP:begin
						ma_res		<= {{24{1'b0}}, ma_data_in};
						ma_done		<= 1;
						stage 		<= 0;
						ma_addr_out	<= 0;
					end
					`EXE_LW_OP,`EXE_LH_OP,`EXE_LHU_OP:begin
						ma_res[7:0]	<= ma_data_in;
						ma_addr_out	<= exmem_alu_in + 1;
						stage 		<= 3;
					end
				endcase
			end
			3:begin
				case(exmem_exec_in)
					`EXE_SW_OP:begin
						ma_data_out	<= exmem_rs2_in[31:24];
						ma_addr_out	<= exmem_alu_in + 3;
						stage 		<= 4;
					end
					default:begin
						stage 		<= 4;
					end
				endcase
			end
			4:begin
				case(exmem_exec_in)
					`EXE_SW_OP:begin
						ma_done		<= 1;
						stage 		<= 0;
						ma_rw_flag	<= 0;
						ma_addr_out	<= 0;
					end
					`EXE_LH_OP:begin
						ma_res[31:8] 	<= {{16{ma_data_in[7]}}, ma_data_in};
						ma_done			<= 1;
						stage 			<= 0;
						ma_addr_out		<= 0;
					end
					`EXE_LHU_OP:begin
						ma_res[31:8] 	<= {{16{1'b0}}, ma_data_in};
						ma_done			<= 1;
						stage 			<= 0;
						ma_addr_out		<= 0;
					end
					`EXE_LW_OP:begin
						ma_res[15:8]	<= ma_data_in;
						ma_addr_out		<= exmem_alu_in + 2;
						stage 			<= 5;
					end
				endcase
			end
			5:begin
				stage 	<= 6;
			end
			6:begin
				ma_res[23:16]	<= ma_data_in;
				ma_addr_out		<= exmem_alu_in + 3;
				stage 			<= 7;
			end
			7:begin
				stage 	<= 8;
			end
			8:begin
				ma_res[31:24]	<= ma_data_in;
				stage 			<= 0;
				ma_done			<= 1;
				ma_addr_out		<= 0;
			end
		endcase
	end else begin
		ma_done	<= 0;
	end
end

always @(*) begin
	if(rst) begin
		ma_ce_flag	<= 0;
	end else begin
		if(ma_done)begin
			ma_ce_flag	<= 0;
		end else if(!ma_done) begin
			case(exmem_exec_in) 
				`EXE_LW_OP,`EXE_LH_OP,`EXE_LB_OP,`EXE_LBU_OP,`EXE_LHU_OP,`EXE_SW_OP,`EXE_SH_OP,`EXE_SB_OP:begin
					ma_ce_flag	<= 1;
				end
				default:begin
					ma_ce_flag	<= 0;
				end
			endcase 
		end
	end
end

always @(*) begin
	if(rst) begin
		mem_res_out 	<= 	0;
		mem_rdest_out 	<= 	0;
		mem_we_out		<=  0;
	end else begin
		case(exmem_exec_in)
			`EXE_LW_OP, `EXE_LH_OP, `EXE_LB_OP,`EXE_LBU_OP, `EXE_LHU_OP:begin
				mem_res_out 	<= ma_res;
			end
			default: begin
				mem_res_out 	<= exmem_alu_in;
			end
		endcase
		mem_rdest_out	<= exmem_rdest_in;
		mem_we_out		<= exmem_we_in;
	end
end

endmodule