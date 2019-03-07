`include "define.v"
module ifetch(
	input wire                 	clk,
	input wire                 	rst,
	input wire 					br_flag,
	input wire[`StallBus] 		stall, 
	input wire[`RegBus]			new_addr,
	input wire[`ByteBus]		mem_data_in,

	output reg[`RegBus]       	if_inst_out,
	output reg[`RegBus]   		if_addr_out,
	output reg[`RegBus]   		if_ctrl_addr,
	output reg 					if_b_stall_req,
	output reg					ctrl_ce
);

reg[`RegBus] 	pc;
reg[`RegBus] 	ibuffer;
reg[3:0] 		stage;

wire[`OpCodeBus]  	opCode;
assign opCode  = ibuffer[6:0];

always @(posedge clk) begin
	if(rst) begin
		if_inst_out		<= 0;
		if_addr_out		<= 0;
		if_ctrl_addr		<= 0;
		ctrl_ce			<= 0;
		if_b_stall_req	<= 0;
		pc				<= 0;
		ibuffer			<= 0;
		stage 			<= 0;
	end else if(br_flag && !stall[1]) begin
		pc 				<= new_addr;
		stage			<= 0;
		ctrl_ce 			<= 0;
		if_b_stall_req 	<= 0;
		if_addr_out		<= 0;
		if_inst_out		<= 0;
	end else begin
		case(stage)
			0:begin
				if(!stall[1] && !stall[2]) begin
					ctrl_ce			<= 1;
					if_ctrl_addr		<= pc;
					stage 			<= 1;
				end
			end
			1:begin
				stage 			<= 2;
				if_ctrl_addr		<= pc + 1;
			end
			2:begin
				ibuffer[7:0]	<= mem_data_in;
				if_ctrl_addr		<= pc + 2;
				stage 			<= 3;
			end
			3:begin
				if(stall[6]) begin
					stage 		<= 6;
				end else begin
					ibuffer[15:8]	<= mem_data_in;
					if_ctrl_addr	<= pc + 3;
					stage 		<= 4;
				end
			end
			4:begin
				if(stall[6]) begin
					stage 		<= 8;
				end else begin
					ibuffer[23:16]	<= mem_data_in;
					stage 			<= 5;
				end
			end
			5:begin
				if_inst_out		<= {mem_data_in, ibuffer[23:0]};
				if_addr_out		<= pc;
				ctrl_ce			<= 0;
				stage 			<= 0;
				case(opCode)
					`JAL_ ,`JALR_, `BRANCH_ :begin
						if_b_stall_req	<= 1;
					end
					default:begin
						if_b_stall_req	<= 0;
						pc <= pc + 4;
					end
				endcase
			end
			6:begin
				if(!stall[6]) begin
					stage <= 7;
					if_ctrl_addr <= pc + 1;
				end
			end
			7:begin
				if_ctrl_addr <= pc + 2;
				stage <= 3;
			end
			8:begin
				if(!stall[6]) begin
					stage <= 9;
					if_ctrl_addr <= pc + 2;
				end
			end
			9:begin
				if_ctrl_addr <= pc + 3;
				stage <= 4;
			end
		endcase
	end
end


endmodule
