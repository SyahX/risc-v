`timescale 1ns / 1ps

`include "defines.v"

module alu_control (
	input wire rst,

	// input control
	input wire[1:0] 			ctrl_ex_AluOp_i,

	// input ALU ctrl 
	input wire					alu_lr_i,
	input wire[`AluOpBus]		alu_op_i,

	// output 
	output reg[`AluCtrlBus]		alu_ctrl
)

endmodule