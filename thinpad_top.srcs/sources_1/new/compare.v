`timescale 1ns / 1ps

`include "defines.v"

module compare (
	input wire[`InstBus]		inst_i,
	input wire[`RegBus]			reg1_data_i,
	input wire[`RegBus]			reg2_data_i,
	
	input wire[`InstAddrBus]	pc_i,
	input wire[`InstAddrBus]	branch_imm_i,
	output reg[`InstAddrBus]	branch_pc_o,

	// output 
	output reg 					ctrl_pc_src_o

);
	wire[6:0] op = inst_i[6:0];
	wire[2:0] funct3 = inst_i[14:12];
	wire[31:0] sign;
	assign sign = (reg1_data_i + (~reg2_data_i) + 1);
	
	// branch pc
	always @ (*) begin
		if (op == `Btype || op == `JAL) begin
			branch_pc_o <= branch_imm_i + pc_i;
		end 
		else if (op == `JALR) begin
			branch_pc_o <= (branch_imm_i + reg1_data_i) & 32'hfffffffe;
		end
		else begin
		    branch_pc_o <= `ZeroWord;      
		end
	end

	// compare
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
					if (sign[31]) begin
						ctrl_pc_src_o <= `Asserted;
					end 
					else begin
						ctrl_pc_src_o <= `DeAsserted;
					end
				end
				`BGE : begin
					if (sign[31]) begin
						ctrl_pc_src_o <= `DeAsserted;
					end 
					else begin
						ctrl_pc_src_o <= `Asserted;
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
					if (reg1_data_i > reg2_data_i || 
						reg1_data_i == reg2_data_i) begin
						ctrl_pc_src_o <= `Asserted;
					end else begin
						ctrl_pc_src_o <= `DeAsserted;
					end
				end
				default : begin
					ctrl_pc_src_o <= `DeAsserted;
				end
			endcase
		end 
		else if (op == `JAL || op == `JALR) begin
		    ctrl_pc_src_o <= `Asserted;
		end
		else begin
			ctrl_pc_src_o <= `DeAsserted;
		end	
	end

endmodule
