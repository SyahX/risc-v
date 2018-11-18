`timescale 1ns / 1ps

`include "defines.v"

module mem (
	input wire rst,
	
	// input control
	input wire 					ctrl_mem_branch_i,
	input wire 					ctrl_mem_read_i,
	input wire 					ctrl_mem_write_i,

	// input alu result
	input wire					alu_branch_take_i,
	input wire[`RegBus]			alu_result_i,

	// input write mem data
	input wire[`RegBus]			mem_write_data_i,

	// output mem
	output reg[`RegBus]			mem_read_data_o,

	// output 
	output reg[`RegBus]			alu_result_o,

	//output
	output reg 					ctrl_pc_src_o
);
	
	always @ (*) begin
		// branch pc take
		alu_result_o <= alu_result_i;
		if (alu_branch_take_i && ctrl_mem_branch_i) begin
			ctrl_pc_src_o <= 1'b1;
		end
	end

endmodule
