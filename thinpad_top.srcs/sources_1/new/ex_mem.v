`timescale 1ns / 1ps

`include "defines.v"

module ex_mem (
	input wire clk,
	input wire rst,

	input wire 					ex_mem_hold,
	
	// control input 
	input wire					ctrl_detection_i,
	input wire					ctrl_wb_RegWrite_i,
	input wire					ctrl_wb_Mem2Reg_i,
	input wire 					ctrl_mem_read_i,
	input wire 					ctrl_mem_write_i,

	// input alu result
	input wire[`RegBus]			alu_result_i,

	// input write mem data
	input wire[`RegBus]			mem_write_data_i,

	// input of register write addr
	input wire[`RegAddrBus]		write_addr_i,

	input wire[`MemOpBus]		mem_op_i,

	// control output 
	output reg					ctrl_detection_o,
	output reg					ctrl_wb_RegWrite_o,
	output reg					ctrl_wb_Mem2Reg_o,
	output reg                  ctrl_mem_read_o,
	output reg 					ctrl_mem_write_o,

	// output alu result
	output reg[`RegBus]			alu_result_o,

	// output write mem data
	output reg[`RegBus]			mem_write_data_o,

	// output of register write addr
	output reg[`RegAddrBus]		write_addr_o,

	output reg[`MemOpBus]		mem_op_o
);

	always @ (posedge clk) begin
		if (rst == `Asserted) begin
			ctrl_detection_o <= `DeAsserted;
			ctrl_wb_RegWrite_o <= `DeAsserted;
			ctrl_wb_Mem2Reg_o <= `DeAsserted;
			ctrl_mem_read_o <= `DeAsserted;
			ctrl_mem_write_o <= `DeAsserted;				

			alu_result_o <= `ZeroWord;

			mem_write_data_o <= `ZeroWord;

			write_addr_o <= `ZeroWord;

			mem_op_o <= 3'b000;
		end
		else if (ex_mem_hold == `DeAsserted) begin
			ctrl_detection_o <= ctrl_detection_i;
			ctrl_wb_RegWrite_o <= ctrl_wb_RegWrite_i;
			ctrl_wb_Mem2Reg_o <= ctrl_wb_Mem2Reg_i;
			ctrl_mem_read_o <= ctrl_mem_read_i;
			ctrl_mem_write_o <= ctrl_mem_write_i;				

			alu_result_o <= alu_result_i;

			mem_write_data_o <= mem_write_data_i;

			write_addr_o <= write_addr_i;

			mem_op_o <= mem_op_i;
		end
	end

endmodule