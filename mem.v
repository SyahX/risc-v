`timescale 1ns / 1ps

`include "defines.v"

module mem (
	input wire rst,
	
	// input control
	input wire 					ctrl_mem_branch_i,
	input wire 					ctrl_mem_read_i,
	input wire 					ctrl_mem_write_i,

	// intput branch pc 
	input wire[`InstAddrBus]	branch_pc_i,

	// input alu result
	input wire					alu_branch_take_i,
	input wire[`RegBus]			alu_result_i,

	// input write mem data
	input wire[`RegBus]			mem_write_data_i,

	// output mem
	output reg[`RegBus]			mem_read_data_o,

	// output 
	output reg[`RegBus]			alu_result_o
);

endmodule
