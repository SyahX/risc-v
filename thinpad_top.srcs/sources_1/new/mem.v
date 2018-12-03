`timescale 1ns / 1ps

`include "defines.v"

module mem (
	// input control
	input wire 					ctrl_detection_i,
	input wire 					ctrl_mem_read_i,
	input wire 					ctrl_mem_write_i,

	// input alu result
	input wire[`RegBus]			alu_result_i,

	// input write mem data
	input wire[`RegBus]			mem_write_data_i,

	input wire[`MemOpBus]		mem_op_i,

	input wire[`RegBus] 		mem_read_data_i,
	output reg[`RegBus] 		mem_write_data_o,
	
	input wire 					ram_finish_i,
	input wire 					sign_finish_i,
	input wire 					uart_finish_i,
	output wire 				mem_finish_o,

	output wire 				mem_ram_use_o,
	output wire 				mem_sign_use_o,
    output wire 				mem_uart_use_o,

	// sram
	output reg[`RamAddrBus] 	mem_ram_addr_o,
    output reg[3:0] 			mem_ram_be_n_o,
    output reg 					mem_ram_ce_n_o,
    output reg 					mem_ram_oe_n_o,
    output reg 					mem_ram_we_n_o,
    
    output wire 				mem_uart_rdn_o,
    output wire 				mem_uart_wrn_o,

	// output mem
	output reg[`RegBus]			mem_read_data_o,

	// output 
	output wire[`RegBus]		alu_result_o,

	// mem_ctrl_ram
	output wire 				mem_ctrl_ram
);
	wire rw;
	assign rw = ~(ctrl_mem_read_i | ctrl_mem_write_i);
	assign alu_result_o = alu_result_i;
	assign mem_finish_o = ram_finish_i | sign_finish_i | uart_finish_i;
	assign mem_ram_use_o = ctrl_detection_i | rw;
	assign mem_sign_use_o = ((alu_result_i == `UartAddrB) ? `DeAsserted : `Asserted) | rw;	
	assign mem_uart_use_o = ((alu_result_i == `UartAddrA) ? `DeAsserted : `Asserted) | rw;	

	assign mem_uart_rdn_o = ~ctrl_mem_read_i;
	assign mem_uart_wrn_o = ~ctrl_mem_write_i;	

	assign mem_ctrl_ram = (ctrl_mem_read_i | ctrl_mem_write_i) 
					      & (~ctrl_detection_i) & (~alu_result_i[22]);   

	always @ (*) begin
		if (ctrl_mem_read_i == `Asserted) begin
			mem_ram_ce_n_o <= `DeAsserted;
			mem_ram_oe_n_o <= `DeAsserted;
			mem_ram_we_n_o <= `Asserted;
			mem_ram_addr_o <= alu_result_i[21:2];
			mem_ram_be_n_o <= 4'b0000;
		end 
		else if (ctrl_mem_write_i == `Asserted) begin
			mem_ram_ce_n_o <= `DeAsserted;
			mem_ram_oe_n_o <= `Asserted;
			mem_ram_we_n_o <= `DeAsserted;
			mem_ram_addr_o <= alu_result_i[21:2];
			case (mem_op_i) 
				`SB : begin
					mem_ram_be_n_o <= {
						(~alu_result_i[1]) | (~alu_result_i[0]),
						(~alu_result_i[1]) | alu_result_i[0],
						alu_result_i[1] | (~alu_result_i[0]),
						alu_result_i[1] | alu_result_i[0]
					};
				end
				`SH : begin
					mem_ram_be_n_o <= {
						~alu_result_i[1],
						~alu_result_i[1],
						alu_result_i[1],
						alu_result_i[1]
					};
				end
				`SW : begin
					mem_ram_be_n_o <= 4'b0000;
				end
				default : begin
					mem_ram_be_n_o <= 4'b1111;
				end
			endcase
		end
		else begin
			mem_ram_ce_n_o <= `Asserted;
			mem_ram_oe_n_o <= `Asserted;
			mem_ram_we_n_o <= `Asserted;
			
			mem_ram_addr_o <= 20'hzzzzz;
			mem_ram_be_n_o <= 4'b1111;
		end
	end

	always @ (*) begin
		if (ctrl_mem_write_i == `Asserted) begin
			case (mem_op_i) 
                `SB : begin
                    mem_write_data_o <= {mem_write_data_i[7:0], 
                                         mem_write_data_i[7:0],
                                         mem_write_data_i[7:0],
                                         mem_write_data_i[7:0]};
                end
                `SH : begin
                    mem_write_data_o <= {mem_write_data_i[15:0], 
                                         mem_write_data_i[15:0]};
                end
                `SW : begin
                    mem_write_data_o <= mem_write_data_i;
                end
                default : begin
                    mem_write_data_o <= `High;
                end
            endcase
		end
		else begin
		    mem_write_data_o <= `High;
		end
	end

	always @ (*) begin
		if (ctrl_mem_read_i == `Asserted) begin
			case (mem_op_i) 
				`LB : begin
					case (alu_result_i[1:0])
						2'b00: begin
							mem_read_data_o <= {{24{mem_read_data_i[7]}},
												mem_read_data_i[7:0]};
						end
						2'b01: begin
							mem_read_data_o <= {{24{mem_read_data_i[15]}},
												mem_read_data_i[15:8]};
						end
						2'b10: begin
							mem_read_data_o <= {{24{mem_read_data_i[23]}},
												mem_read_data_i[23:16]};
						end
						2'b11: begin
							mem_read_data_o <= {{24{mem_read_data_i[31]}},
												mem_read_data_i[31:24]};
						end
					endcase
				end
				`LH : begin
					if (alu_result_i[1] == 1'b0) begin
						mem_read_data_o <= {{16{mem_read_data_i[15]}},
											mem_read_data_i[15:0]};
					end
					else begin
						mem_read_data_o <= {{16{mem_read_data_i[31]}},
											mem_read_data_i[31:16]};
					end
				end
				`LW : begin
					mem_read_data_o <= mem_read_data_i;
				end
				`LBU : begin
					case (alu_result_i[1:0])
						2'b00: begin
							mem_read_data_o <= {24'b0, mem_read_data_i[7:0]};
						end
						2'b01: begin
							mem_read_data_o <= {24'b0, mem_read_data_i[15:8]};
						end
						2'b10: begin
							mem_read_data_o <= {24'b0, mem_read_data_i[23:16]};
						end
						2'b11: begin
							mem_read_data_o <= {24'b0, mem_read_data_i[31:24]};
						end
					endcase
				end
				`LHU : begin
					if (alu_result_i[1] == 1'b0) begin
						mem_read_data_o <= {16'b0, mem_read_data_i[15:0]};
					end
					else begin
						mem_read_data_o <= {16'b0, mem_read_data_i[31:16]};
					end
				end
				default : begin
				end
			endcase
		end
	end

endmodule
