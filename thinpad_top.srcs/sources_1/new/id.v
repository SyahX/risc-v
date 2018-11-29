`timescale 1ns / 1ps

`include "defines.v"

module id (
	input wire rst,
    
    input wire[`InstAddrBus]    pc_i,
	input wire[`InstBus]		inst_i,

	// get data from regfile
	input wire[`RegBus]			reg1_data_i,
	input wire[`RegBus]			reg2_data_i,					

	// para to regfile
	output reg[`RegBus]			reg1_data_o,
	output reg[`RegBus]			reg2_data_o,
	output reg[`RegAddrBus]		reg1_addr_o,
	output reg[`RegAddrBus] 	reg2_addr_o,

	// imm gen
	output reg[`ImmBus]			imm_data_o,

	// inst for ALU
	output reg 					alu_lr_o,
	output reg[`AluOpBus]		alu_op_o,
	
	// write register
	output reg[`RegAddrBus]		write_addr_o,

	// branch pc
	output reg[`InstAddrBus]	branch_imm_o
);
	
	wire[6:0] op = inst_i[6:0];
	wire[2:0] funct3 = inst_i[14:12];

	// register
	always @ (*) begin

		reg1_data_o <= reg1_data_i;
		reg2_data_o <= reg2_data_i;

		reg1_addr_o <= inst_i[19:15];
		reg2_addr_o <= inst_i[24:20];
	end

	// Alu
	always @ (*) begin
	    if (op == `Rtype || (op == `Itype && funct3 == 3'b101)) begin
		    alu_lr_o <= inst_i[30];
		end
		else begin
		    alu_lr_o <= 1'b0;
		end
		alu_op_o <= funct3;

		write_addr_o <= inst_i[11:7];
	end

	// imm
	always @ (*) begin
		case (op) 
			`Itype : begin
				imm_data_o <= {{20{inst_i[31]}}, inst_i[31:20]};
			end
			`Stype : begin
				imm_data_o <= {{20{inst_i[31]}}, 
				               inst_i[31:25], 
				               inst_i[11:7]};
			end
			`Ltype : begin
				imm_data_o <= {{20{inst_i[31]}}, inst_i[31:20]};
			end
			`JALR : begin
				imm_data_o <= pc_i + 4;
			end
			`JAL : begin
				imm_data_o <= pc_i + 4;
			end
			`LUI : begin
				imm_data_o <= {inst_i[31:12], 12'b0};
			end
			`AUIPC : begin
				imm_data_o <= {inst_i[31:12], 12'b0} + pc_i;
			end
			default : begin
				imm_data_o <= `ZeroWord;
			end
		endcase
	end

	// branch imm
	always @ (*) begin
		case (op) 
			`JALR : begin
				branch_imm_o <= {{20{inst_i[31]}}, inst_i[31:20]};
			end
			`JAL : begin
				branch_imm_o <= {{12{inst_i[31]}},
								 inst_i[19:12],
								 inst_i[20],
								 inst_i[30:21],
								 1'b0};
			end
			`Btype : begin
				branch_imm_o <= {{20{inst_i[31]}}, 
				 				 inst_i[7], 
				 				 inst_i[30:25], 
				 				 inst_i[11:8], 
				 				 1'b0};
			end
			default : begin
				branch_imm_o <= `ZeroWord;
			end
		endcase
	end

endmodule