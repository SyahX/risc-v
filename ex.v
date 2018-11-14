`timescale 1ns / 1ps

`include "defines.v"

module ex (
	input wire rst,

	// input control
	input wire 					ctrl_AluSrc_i,
	input wire 					ctrl_AluFinalOp_i,
	
	// input of pc
	input wire[`InstAddrBus]	pc_i,

	// input resgiter
	input wire[`RegBus]			reg1_data_i,
	input wire					reg2_ce_i,
	input wire[`RegBus]			reg2_data_i,

	// input imm
	input wire[`ImmBus]			imm_data_i,

	// output branch pc 
	output reg 					branch_ce_o,
	output reg[`InstAddrBus]	branch_pc_o,

	// output alu result
	output reg[`RegBus]			alu_result_o,

	// output write mem data
	output reg[`RegBus]			mem_write_data_o
);

endmodule