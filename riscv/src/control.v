`include "define.v"

module stall(
	input wire rst,
	input wire rdy,
	input wire if_mem_stall_in,
	input wire if_b_stall_in,
	input wire id_data_stall_in,
	input wire mem_ma_stall_in,

	output reg[`StallBus] 	stall
);

always @(*) begin
	if(rst) begin
		stall 			= 7'b0000000;
	end else if(!rdy) begin
		stall 			= 7'b0111110;
	end else if(mem_ma_stall_in) begin
		stall 			= 7'b1011111;
	end else if(id_data_stall_in) begin
		stall 			= 7'b0000110;	
	end else if(if_b_stall_in) begin
		stall 			= 7'b0000100;
	end else if(if_mem_stall_in) begin
		stall 			= 7'b0000010;
	end else begin
		stall 			= 0;
	end
end
endmodule

module control(
	input wire rst, 
	input wire rdy,

	input wire 					inst_ce,
	input wire[`RegBus]			if_inst_addr_in,

	input wire 					data_ce,
	input wire[`ByteBus]		mem_data_in,
	input wire[`RegBus]			mem_data_addr_in,
	input wire					mem_rw_in, 

	output reg[`RegBus] 		ma_addr_out,
	output reg[`ByteBus]		ma_data_out,
	output reg 					ma_rw_out,

	output reg 					if_ma_stall,
	output reg 					mem_ma_stall
);

always @(*) begin
	if(rst) begin
		ma_addr_out	 	<= 0;
		ma_data_out     <= 0;
		ma_rw_out 		<= 0;
		if_ma_stall		<= 0;
		mem_ma_stall 	<= 0;
	end else if(rdy) begin
		if(data_ce) begin
			if(inst_ce) begin
				if_ma_stall	<=	1;
			end else begin
				if_ma_stall	<=	0;
			end
			mem_ma_stall	<= 1;
			ma_addr_out		<= 	mem_data_addr_in;
			ma_rw_out 		<= 	mem_rw_in;
			ma_data_out		<= 	mem_data_in;
		end else if(inst_ce) begin
			mem_ma_stall	<=	0;
			if_ma_stall		<= 	1;
			ma_addr_out		<= 	if_inst_addr_in;
			ma_rw_out 		<= 	0;
		end else begin
			if_ma_stall		<= 0;
			mem_ma_stall 	<= 0;
		end
	end
end

endmodule