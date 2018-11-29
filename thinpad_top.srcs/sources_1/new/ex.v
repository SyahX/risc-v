`timescale 1ns / 1ps

`include "defines.v"

module ex (
	input wire rst,

	// input control
	input wire 					ctrl_ex_AluSrc_i,

	// input alu
	input wire[`AluCtrlBus] 	alu_ctrl_i,
	
	// input of pc
	input wire[`InstAddrBus]	pc_i,

	// input resgiter
	input wire[`RegBus]			reg1_data_i,
	input wire[`RegBus]			reg2_data_i,

	// input imm
	input wire[`ImmBus]			imm_data_i,

	// output alu result
	output reg[`RegBus]			alu_result_o,

	// output write mem data
	output wire[`RegBus]		mem_write_data_o
);
    wire[`RegBus] reg1;
    reg[`RegBus] reg2;
	assign reg1 = reg1_data_i;
	assign mem_write_data_o = reg2_data_i;
	
	wire[`RegBus] sign;
	assign sign = (reg1 + (~reg2) + 1);
	
	always @ (*) begin
		if (ctrl_ex_AluSrc_i == `Asserted) begin
			reg2 <= imm_data_i[`RegBus];
		end
		else begin
			reg2 <= reg2_data_i[`RegBus];
		end
	end

	always @ (*) begin
		case (alu_ctrl_i)
			`EXE_ADD : begin
				alu_result_o <= reg1 + reg2;
			end
			`EXE_SUB : begin
				alu_result_o <= reg1 + (~reg2) + 1;
			end
			`EXE_SLL : begin
				alu_result_o <= reg1 << reg2[4:0];
			end
			`EXE_SLT : begin
				if (sign[31]) begin
					alu_result_o <= 32'b1;
				end 
				else begin
					alu_result_o <= 32'b0;
				end
			end
			`EXE_SLTU : begin
				if (reg1 < reg2) begin
					alu_result_o <= 32'b1;
				end
				else begin
					alu_result_o <= 32'b0;
				end
			end
			`EXE_XOR : begin
				alu_result_o <= reg1 ^ reg2;
			end
			`EXE_SRL : begin
				alu_result_o <= reg1 >> reg2[4:0];
			end
			`EXE_SRA : begin
				alu_result_o <= ({32{reg1[31]}} << (6'd32 - {1'b0, reg2[4:0]})) | (reg1 >> reg2[4:0]);
			end
			`EXE_OR : begin
				alu_result_o <= reg1 | reg2;
			end
			`EXE_AND : begin
				alu_result_o <= reg1 & reg2;
			end
			`EXE_IMM : begin
				alu_result_o <= reg2;
			end
			default : begin
				alu_result_o <= `ZeroWord;
			end
		endcase
	end

endmodule