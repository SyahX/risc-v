`timescale 1ns / 1ps

`include "defines.v"

module mem (
	input wire rst,
	
	// input control
	input wire 					ctrl_mem_read_i,
	input wire 					ctrl_mem_write_i,

	// input alu result
	input wire[`RegBus]			alu_result_i,

	// input write mem data
	input wire[`RegBus]			mem_write_data_i,

	input wire[`MemOpBus]		mem_op_i,

	// output mem
	output reg[`RegBus]			mem_read_data_o,

	// output 
	output reg[`RegBus]			alu_result_o

);
	
	always @ (*) begin
		alu_result_o <= alu_result_i;
	end

endmodule
