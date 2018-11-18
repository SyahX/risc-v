`timescale 1ns / 1ps

`include "defines.v"

module alu_control (
	input wire rst,

	// input control
	input wire[`CtrlAluOpBus] 	ctrl_ex_AluOp_i,

	// input ALU ctrl 
	input wire					alu_lr_i,
	input wire[`AluOpBus]		alu_op_i,

	// output 
	output reg[`AluCtrlBus]		alu_ctrl_o
);

	always @ (*) begin
		alu_ctrl_o <= {alu_lr_i, alu_op_i[`AluOpBus]};
	end

endmodule