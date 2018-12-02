`timescale 1ns / 1ps

`include "defines.v"

module uart_ctrl (
    //output wire[2:0] debug,
	input wire rst,
	input wire clk,

	input wire[`RegBus]		uart_write_data_i,
	input wire 				data_ready_i,
	input wire 				rdn_i,
	input wire 				tbre_i, 
	input wire 				tsre_i,
	input wire 				wrn_i,
	
	input wire[7:0]		    uart_read_data_i,
	output reg[`RegBus]		uart_read_data_o,

	output reg[7:0]    		uart_write_data_o,
	output reg 				rdn_o,
	output reg 				wrn_o,
	output wire				uart_finish_o
);
	reg[2:0] state;
	assign uart_finish_o = (rst == `Asserted || state == 3'b111) 
	                       ? `DeAsserted : `Asserted;
	//assign debug = state;
	                       
	always @(posedge clk or posedge rst) begin
		if (rst == `Asserted) begin
			state <= 3'b000;
			rdn_o <= `Asserted;
			wrn_o <= `Asserted;
			uart_read_data_o <= `High;
			uart_write_data_o <= `High;
		end
		else begin
			case (state)
				3'b000 : begin
					rdn_o <= `Asserted;
					wrn_o <= `Asserted;
					uart_read_data_o <= `High;
					if (rdn_i == `DeAsserted) begin
						state <= 3'b001;
						uart_write_data_o <= `High;
					end 
					else begin
						state <= 3'b011;
						uart_write_data_o <= uart_write_data_i[7:0];
					end
				end
				3'b001 : begin
				    rdn_o <= `DeAsserted;
					if (data_ready_i == `Asserted) begin
						state <= 3'b010;
					end
				end
				3'b010 : begin
					uart_read_data_o <= {24'b0, uart_read_data_i};
					state <= 3'b111;
				end
				3'b011 : begin
					wrn_o <= `DeAsserted;
					state <= 3'b100;
				end
				3'b100 : begin
					wrn_o <= `Asserted;
					uart_write_data_o <= `High;
					state <= 3'b101;
				end
				3'b101 : begin
					if (tbre_i == `Asserted) begin
						state <= 3'b110;
					end
				end
				3'b110 : begin
				    if (tsre_i == `Asserted) begin
                        state <= 3'b111;
                    end
				end
				3'b111 : begin
					rdn_o <= `Asserted;
					wrn_o <= `Asserted;
					uart_read_data_o <= `High;
                    uart_write_data_o <= `High;
				end
			endcase
		end
	end

endmodule