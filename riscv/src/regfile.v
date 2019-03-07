`include "define.v"

module reg_file(
	input clk,
	input rst,

	input [`RegAddrBus] w_addr,
	input [`RegBus] w_data,
	input we,        

	input re_a,
	input [`RegAddrBus] r_addr_a,
	output reg [`RegBus] r_data_a,
    
	input re_b,
	input [`RegAddrBus] r_addr_b,
	output reg [`RegBus] r_data_b
);

reg [`RegBus] regs[`RegCnt-1:0]; 

integer i;

always @(posedge clk) begin
	if(rst) begin
        for(i = 0; i < `RegCnt; i = i + 1)begin
          regs[i] <= 0;
        end
    end
	else begin
		if(we == 1 && w_addr) 
		begin
			regs[w_addr] <= w_data;
		end
	end
end


always @(*) begin
	if(rst == 1) begin
		r_data_a <= 0;
	end
	else if(r_addr_a == 5'b0) begin
		r_data_a <= 0;
	end
	else if(w_addr == r_addr_a && 
        we && re_a) begin
		r_data_a <= w_data;
	end
	else begin
		if(re_a == 0)
			r_data_a <= 0;
		else
			r_data_a <= regs[r_addr_a];
	end
end

always @(*) begin
	if(rst == 1) begin
		r_data_b <= 0;
	end
	else if(r_addr_b == 5'b0) begin
		r_data_b <= 0;
	end
	else if(w_addr == r_addr_b && 
        we && re_b) begin
		r_data_b <= w_data;
	end
	else begin
		if(re_b == 0)
			r_data_b <= 0;
		else
			r_data_b <= regs[r_addr_b];
	end
end


endmodule