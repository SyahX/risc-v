`timescale 1ns / 1ps

`include "defines.v"

module uart_detection (
	input wire 				ctrl_mem_read_i,
	input wire 				ctrl_mem_write_i,
	input wire[`RegBus]		alu_result_i,
	input wire 				mem_ctrl_detection_i, 

	output reg 				ex_ctrl_detection_o,
	output reg 				ctrl_detection_o
);

	always @ (*) begin
		if ((ctrl_mem_write_i == `Asserted ||
			 ctrl_mem_read_i == `Asserted) &&
			(alu_result_i == `UartAddrA || 
			 alu_result_i == `UartAddrB)) begin
			ex_ctrl_detection_o <= `Asserted;
			ctrl_detection_o <= `Asserted;	 	
		end
		else begin
			ex_ctrl_detection_o <= `DeAsserted;
			ctrl_detection_o <= mem_ctrl_detection_i;
		end
	end

endmodule