`timescale 1ns / 1ps

`include "defines.v"

module uart (
	input wire 				uart_rdn,
	input wire 				uart_wrn,
    input wire[7:0] 		uart_data_i,

    output reg 				uart_data_ready,
	output reg 				uart_tbre, 
	output reg 				uart_tsre,
    output reg[7:0] 		uart_data_o
);
	
	reg[7:0]  data;

	always @ (*) begin
		if (uart_rdn == `DeAsserted) begin
			uart_tbre <= `DeAsserted;
			uart_tsre <= `DeAsserted;
			uart_data_o <= 8'h43;
			uart_data_ready <= `Asserted;
		end 
		else if (uart_wrn == `DeAsserted) begin
			data <= uart_data_i;
			uart_tbre <= `DeAsserted;
			uart_tsre <= `DeAsserted;
			uart_data_o <= 8'hzz;
			uart_data_ready <= `DeAsserted;
		end
		else begin
			uart_tbre <= `Asserted;
			uart_tsre <= `Asserted;
			uart_data_o <= 8'hzz;
			uart_data_ready <= `Asserted;
		end
	end

endmodule
