`timescale 1ns / 1ps

`include "defines.v"

module pc_reg (
	input wire		clk,
	input wire		rst,

	input wire 					ctrl_pc_src_i,
	input wire[`InstAddrBus]	pc_i,
	input wire[`InstAddrBus]	branch_pc_i,

	output reg[`InstAddrBus]	pc_o,
	output reg[`InstAddrBus]	next_pc_o,
);

	always @ (posedge clk) begin
		if (rst == `Asserted) begin
			pc_o <= 32'h00000000;
		end
		else begin
			if (pc_src == `Asserted) begin
				pc_o <= branch_pc_i;
			end
			else begin
				pc_o <= pc_i;
			end
		end
		next_pc_o <= pc_o + 4'h4;
	end

endmodule


