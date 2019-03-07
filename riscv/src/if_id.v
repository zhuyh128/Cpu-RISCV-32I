`include "define.v"
module if_id(
	input clk,
	input rst,
	input wire[`StallBus]	stall,
	input wire[`RegBus]		if_inst_in,
	input wire[`RegBus] 	if_addr_in,
	output reg[`RegBus]		id_addr_out,
	output reg[`RegBus]		id_inst_out
);

always @(posedge clk) begin
	if(rst) begin
		id_inst_out	<= 0;
        id_addr_out 	<= 0;
    end else if(!stall[1]) begin
    	id_inst_out	<= if_inst_in;
        id_addr_out 	<= if_addr_in;
    end else if(stall[1] && !stall[2]) begin
    	id_inst_out   <= 0;
        id_addr_out   <= 0;
    end
end
endmodule