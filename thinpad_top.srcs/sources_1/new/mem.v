`timescale 1ns / 1ps

`include "defines.v"

module mem (
	input wire rst,
	
	// input control
	input wire 					ctrl_mem_read_i,
	input wire 					ctrl_mem_write_i,

	// input alu result
	input wire[`RegBus]			alu_result_i,

	// input write mem data
	input wire[`RegBus]			mem_write_data_i,

	input wire[`MemOpBus]		mem_op_i,

	input wire[`RegBus] 		mem_ram_data,

	output reg[`RamAddrBus] 	mem_ram_addr,
    output reg[3:0] 			mem_ram_be_n,
    output reg 					mem_ram_ce_n,
    output reg 					mem_ram_oe_n,
    output reg 					mem_ram_we_n,

	// output mem
	output reg[`RegBus]			mem_read_data_o,

	// output 
	output wire[`RegBus]		alu_result_o

);
	assign alu_result_o = alu_result_i;

	always @ (*) begin
		if (ctrl_mem_read_i == `Asserted) begin
			mem_ram_ce_n <= `DeAsserted;
			mem_ram_oe_n <= `DeAsserted;
			mem_ram_we_n <= `Asserted;
			mem_ram_addr <= alu_result_i[21:2];
			mem_ram_be_n <= 4'b0000;
		end 
		else if (ctrl_mem_write_i == `Asserted) begin
			mem_ram_ce_n <= `DeAsserted;
			mem_ram_oe_n <= `Asserted;
			mem_ram_we_n <= `DeAsserted;
			mem_ram_addr <= alu_result_i[21:2];
			case (mem_op_i) 
				`SB : begin
					mem_ram_be_n <= {
						(~alu_result_i[1]) | (~alu_result_i[0]),
						(~alu_result_i[1]) | alu_result_i[0],
						alu_result_i[1] | (~alu_result_i[0]),
						alu_result_i[1] | alu_result_i[0]
					};
				end
				`SH : begin
					mem_ram_be_n <= {
						~alu_result_i[1],
						~alu_result_i[1],
						alu_result_i[1],
						alu_result_i[1],
					};
				end
				`SW : begin
					mem_ram_be_n <= 4'b0000;
				end
				defalut : begin
					mem_ram_be_n <= 4'b1111;
				end
			endcase
		end
		else begin
			mem_ram_ce_n <= `Asserted;
			mem_ram_oe_n <= `Asserted;
			mem_ram_we_n <= `Asserted;
		end
	end

	always @ (negedge clk) begin
		if (ctrl_mem_write_i == `Asserted) begin
			mem_ram_data <= mem_write_data_i;
		end
	end

	always @ (*) begin
		if (ctrl_mem_read_i == `Asserted) begin
			case (mem_op_i) 
				`LB : begin
					case (alu_result_i[1:0])
						2'b00: begin
							mem_read_data_o <= {{24{mem_ram_data[7]}},
												mem_ram_data[7:0]};
						end
						2'b01: begin
							mem_read_data_o <= {{24{mem_ram_data[15]}},
												mem_ram_data[15:8]};
						end
						2'b10: begin
							mem_read_data_o <= {{24{mem_ram_data[23]}},
												mem_ram_data[23:16]};
						end
						2'b11: begin
							mem_read_data_o <= {{24{mem_ram_data[31]}},
												mem_ram_data[31:24]};
						end
					endcase
				end
				`LH : begin
					if (alu_result_i[1] == 1'b0) begin
						mem_read_data_o <= {{16{mem_ram_data[15]}},
											mem_ram_data[15:0]};
					end
					else begin
						mem_read_data_o <= {{16{mem_ram_data[31]}},
											mem_ram_data[31:16]};
					end
				end
				`LW : begin
					mem_ram_addr <= alu_result_i[21:2];
					mem_read_data_o <= mem_ram_data;
				end
				`LBU : begin
					case (alu_result_i[1:0])
						2'b00: begin
							mem_read_data_o <= {24'b0, mem_ram_data[7:0]};
						end
						2'b01: begin
							mem_read_data_o <= {24'b0, mem_ram_data[15:8]};
						end
						2'b10: begin
							mem_read_data_o <= {24'b0, mem_ram_data[23:16]};
						end
						2'b11: begin
							mem_read_data_o <= {24'b0, mem_ram_data[31:24]};
						end
					endcase
				end
				`LHU : begin
					if (alu_result_i[1] == 1'b0) begin
						mem_read_data_o <= {16'b0, mem_ram_data[15:0]};
					end
					else begin
						mem_read_data_o <= {16'b0, mem_ram_data[31:16]};
					end
				end
				default : begin
				end
			endcase
		end
	end

endmodule
