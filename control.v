`timescale 1ns / 1ps

`include "defines.v"

module control (
	input wire rst,

	input wire[`InstBus]		inst_i,

	// control output 
	output reg					ctrl_wb_RegWrite_o,
	output reg					ctrl_wb_Mem2Reg_o,
	output reg 					ctrl_mem_branch_o,
	output reg 					ctrl_mem_read_o,
	output reg 					ctrl_mem_write_o,
	output reg					ctrl_ex_AluSrc_o,
	output reg[1:0] 			ctrl_ex_AluOp_o
);

endmodule