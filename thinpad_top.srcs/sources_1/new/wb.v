`timescale 1ns / 1ps

`include "defines.v"

module wb (
	input wire rst,

	// ctrl
	input wire 				ctrl_wb_Mem2Reg_i,

	// input mem
	input wire[`RegBus]		mem_read_data_i,

	// input alu
	input wire[`RegBus]		alu_result_i,
	
	// data write to reg
	output reg[`RegBus]		write_data_o,
);
	always @ (*) begin
		if (rst == `Assert) begin

		end
		else if (ctrl_wb_Mem2Reg_i == `Asserted) begin
			write_data_o <= mem_read_data_i;
		end
		else begin
			write_data_o <= alu_result_i;
		end
	end

endmodule