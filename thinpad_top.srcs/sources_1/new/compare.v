`timescale 1ns / 1ps

`include "defines.v"

module compare (
	input wire[`InstBus]	inst_i,
	input wire[`RegBus]		reg1_data_i,
	input wire[`RegBus]		reg2_data_i,

	// output 
	output reg 				ctrl_pc_src_o

);
	wire[6:0] op = inst_i[6:0];
	wire[2:0] funct3 = inst_i[14:12];
	always @ (*) begin
		if (op == `Btype) begin
			case (funct3)
				`BEQ : begin
					if (reg1_data_i == reg2_data_i) begin
						ctrl_pc_src_o <= `Asserted;
					end else begin
						ctrl_pc_src_o <= `DeAsserted;
					end
				end
				`BNE : begin
					if (reg1_data_i != reg2_data_i) begin
						ctrl_pc_src_o <= `Asserted;
					end else begin
						ctrl_pc_src_o <= `DeAsserted;
					end
				end
				`BLT : begin
					if (reg1_data_i == reg2_data_i) begin
						ctrl_pc_src_o <= `Asserted;
					end else begin
						ctrl_pc_src_o <= `DeAsserted;
					end
				end
				`BGE : begin
					if (reg1_data_i == reg2_data_i) begin
						ctrl_pc_src_o <= `Asserted;
					end else begin
						ctrl_pc_src_o <= `DeAsserted;
					end
				end
				`BLTU : begin
					if (reg1_data_i < reg2_data_i) begin
						ctrl_pc_src_o <= `Asserted;
					end else begin
						ctrl_pc_src_o <= `DeAsserted;
					end
				end
				`BGEU : begin
					if (reg1_data_i >= reg2_data_i) begin
						ctrl_pc_src_o <= `Asserted;
					end else begin
						ctrl_pc_src_o <= `DeAsserted;
					end
				end
				default : begin
					ctrl_pc_src_o <= `DeAsserted;
				end
			endcase
		end else begin
			ctrl_pc_src_o <= `DeAsserted;
		end	
	end

endmodule
