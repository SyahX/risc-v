`timescale 1ns / 1ps

`include "defines.v"

module control (
	input wire 					ctrl_mux_i,

	input wire[`InstBus]		inst_i,

	// control output 
	output reg					ctrl_wb_RegWrite_o,
	output reg					ctrl_wb_Mem2Reg_o,
	output reg 					ctrl_mem_read_o,
	output reg 					ctrl_mem_write_o,
	output reg					ctrl_ex_AluSrc_o, 
	output reg[`CtrlAluOpBus] 	ctrl_ex_AluOp_o,
	output reg 					ctrl_if_flush_o
);
	wire[6:0] op = inst_i[6:0];
	wire[2:0] funct3 = inst_i[14:12];
	wire[6:0] funct7 = inst_i[31:25];

	always @ (*) begin
		if (ctrl_mux_i == `Asserted) begin
			ctrl_wb_RegWrite_o <= `DeAsserted;
			ctrl_wb_Mem2Reg_o <= `DeAsserted;
			ctrl_mem_read_o <= `DeAsserted;
			ctrl_mem_write_o <= `DeAsserted;
			ctrl_ex_AluSrc_o <= `DeAsserted;
			ctrl_ex_AluOp_o <= 2'b00;
			ctrl_if_flush_o <= `DeAsserted;
		end
		else begin
			//ori
			if ((op == `Itype) && (funct3 == 3'b110)) begin
				ctrl_wb_RegWrite_o <= `Asserted;
				ctrl_wb_Mem2Reg_o <= `DeAsserted;
				ctrl_mem_read_o <= `DeAsserted;
				ctrl_mem_write_o <= `DeAsserted;
				ctrl_ex_AluSrc_o <= `Asserted;
				ctrl_ex_AluOp_o <= 2'b00;
			end
			else begin
		        ctrl_wb_RegWrite_o <= `DeAsserted;
                ctrl_wb_Mem2Reg_o <= `DeAsserted;
                ctrl_mem_read_o <= `DeAsserted;
                ctrl_mem_write_o <= `DeAsserted;
                ctrl_ex_AluSrc_o <= `DeAsserted;
                ctrl_ex_AluOp_o <= 2'b00;
			end
		end
	end

endmodule