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
		case (ctrl_ex_AluOp_i)
			`AluOp_Itype : 
			begin
				alu_ctrl_o <= {alu_lr_i, alu_op_i};
			end
			`AluOp_Rtype : 
			begin
				alu_ctrl_o <= {alu_lr_i, alu_op_i};
			end
			default : 
			begin
				alu_ctrl_o <= `EXE_NOP;
			end
		endcase
	end

endmodule