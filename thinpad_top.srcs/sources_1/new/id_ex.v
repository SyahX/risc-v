`timescale 1ns / 1ps

`include "defines.v"

module id_ex (
	input wire clk,
	input wire rst,
	
	// control input 
	input wire					ctrl_wb_RegWrite_i,
	input wire					ctrl_wb_Mem2Reg_i,
	input wire 					ctrl_mem_read_i,
	input wire 					ctrl_mem_write_i,
	input wire					ctrl_ex_AluSrc_i,
	input wire[`CtrlAluOpBus] 	ctrl_ex_AluOp_i,

	// input register data
	input wire[`RegBus]			reg1_data_i,
	input wire[`RegBus]			reg2_data_i,
	input wire[`RegAddrBus]		reg1_addr_i,
    input wire[`RegAddrBus]     reg2_addr_i,
	
	// input of imm
	input wire[`ImmBus]			imm_data_i,

	// input ALU ctrl 
	input wire					alu_lr_i,
	input wire[`AluOpBus]		alu_op_i,

	// input of register write addr
	input wire[`RegAddrBus]		write_addr_i,

	// control output 
	output reg					ctrl_wb_RegWrite_o,
	output reg					ctrl_wb_Mem2Reg_o,
	output reg 					ctrl_mem_read_o,
	output reg 					ctrl_mem_write_o,
	output reg					ctrl_ex_AluSrc_o,
	output reg[`CtrlAluOpBus] 	ctrl_ex_AluOp_o,

	// output register data
	output reg[`RegBus]			reg1_data_o,
	output reg[`RegBus]			reg2_data_o,
	output reg[`RegAddrBus]		reg1_addr_o,
    output reg[`RegAddrBus]     reg2_addr_o,
	
	// output of imm
	output reg[`ImmBus]			imm_data_o,

	// output ALU ctrl 
	output reg					alu_lr_o,
	output reg[`AluOpBus]		alu_op_o,

	// output of register write addr
	output reg[`RegAddrBus]		write_addr_o
);

	always @ (posedge clk) begin
		if (rst == `Asserted) begin
			ctrl_wb_RegWrite_o <= `DeAsserted;
			ctrl_wb_Mem2Reg_o <= `DeAsserted;
			ctrl_mem_read_o <= `DeAsserted;
			ctrl_mem_write_o <= `DeAsserted;				
			ctrl_ex_AluSrc_o <=	`DeAsserted;		
			ctrl_ex_AluOp_o <= 4'b0000;

			reg1_data_o <= `ZeroWord;
			reg2_data_o <= `ZeroWord;

			imm_data_o <= `ZeroWord;

			alu_lr_o <= 1'b0;
			alu_op_o <= 3'b000;
			
			reg1_addr_o <= 5'b00000;
            reg2_addr_o <= 5'b00000;

			write_addr_o <= 5'b00000;
		end
		else begin
			ctrl_wb_RegWrite_o <= ctrl_wb_RegWrite_i;
			ctrl_wb_Mem2Reg_o <= ctrl_wb_Mem2Reg_i;
			ctrl_mem_read_o <= ctrl_mem_read_i;
			ctrl_mem_write_o <= ctrl_mem_write_i;				
			ctrl_ex_AluSrc_o <=	ctrl_ex_AluSrc_i;		
			ctrl_ex_AluOp_o <= ctrl_ex_AluOp_i;

			reg1_data_o <= reg1_data_i;
			reg2_data_o <= reg2_data_i;
			
			reg1_addr_o <= reg1_addr_i;
            reg2_addr_o <= reg2_addr_i;

			imm_data_o <= imm_data_i;

			alu_lr_o <= alu_lr_i;
			alu_op_o <= alu_op_i;

			write_addr_o <= write_addr_i;
		end
	end

endmodule