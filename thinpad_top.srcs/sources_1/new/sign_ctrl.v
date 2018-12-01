`timescale 1ns / 1ps

`include "defines.v"

module sign_ctrl (
	input wire rst,
	input wire clk,

	input wire 				tsre_i,
	input wire 				data_ready_i,

    output wire[`RegBus]	sign_data_o,
	output wire				sign_finish_o
);
	assign sign_finish_o = `DeAsserted;
	assign sign_data_o = rst ? `High : {30'b0, data_ready_i, tsre_i};

endmodule