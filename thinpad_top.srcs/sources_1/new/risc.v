`timescale 1ns / 1ps

`include "defines.v"

module risc (
	input wire clk,
	input wire clk_11M,
	input wire rst,
	
	output wire[15:0]           debug,

	output wire 				sram_ctrl,

	// rom
	inout  wire[`RegBus]		rom_data,

	output wire[19:0]		    rom_addr,
	output wire					rom_ce_n,

	// ram
	inout wire[`RegBus] 		ram_data,

	output wire[`RamAddrBus] 	ram_addr,
    output wire[3:0] 			ram_be_n,
    output wire 				ram_ce_n,
    output wire 				ram_oe_n,
    output wire 				ram_we_n,

    // uart
    inout wire[7:0]			    uart_data,
    input wire 					uart_data_ready,
    input wire 					uart_tbre,
    input wire 					uart_tsre,
    
    output wire 				uart_rdn,
    output wire 				uart_wrn
);
	wire mem_ctrl_ram;
	assign sram_ctrl = mem_ctrl_ram;
	
	// pc_reg
	wire pc_hold_i;
	wire[`InstAddrBus] pc;
	wire[`InstAddrBus] next_pc_i;
	assign next_pc_i = pc + 4;
	assign rom_addr = pc[21:2];
	
	// if_id
	wire ctrl_if_flush;
	wire if_id_hold;

	// id
	wire[`InstAddrBus] id_pc_i;
	wire[`InstBus] id_inst_i;
	wire[`RegAddrBus] id_reg1_addr_i;
	wire[`RegAddrBus] id_reg2_addr_i;
	assign id_reg1_addr_i = id_inst_i[19:15];
	assign id_reg2_addr_i = id_inst_i[24:20];

	wire[`InstAddrBus] branch_imm;
	wire[1:0] id_alu_mux1;
	wire[1:0] id_alu_mux2;
	wire[`RegBus] id_reg1_data;
	wire[`RegBus] id_reg2_data;
	wire[`InstAddrBus] branch_pc;
	wire ctrl_pc_src;
	wire id_ctrl_hold;

	wire[`RegBus] id_reg1_data_i;
	wire[`RegBus] id_reg2_data_i;

	wire[`RegAddrBus] id_reg1_addr_o;
	wire[`RegAddrBus] id_reg2_addr_o;
	wire[`RegBus] id_reg1_data_o;
	wire[`RegBus] id_reg2_data_o;
	wire[`ImmBus] id_imm_data_o;
	wire id_alu_lr_o;
	wire[`AluOpBus] id_alu_op_o;
	wire[`RegAddrBus] id_write_addr_o;

	wire id_ctrl_wb_RegWrite_o;
	wire id_ctrl_wb_Mem2Reg_o;
	wire id_ctrl_mem_read_o;
	wire id_ctrl_mem_write_o;
	wire id_ctrl_ex_AluSrc_o; 
	wire[`CtrlAluOpBus] id_ctrl_ex_AluOp_o;

	// id_ex
	wire id_ex_flush;

	// ex
	wire ex_ctrl_wb_RegWrite_i;
	wire ex_ctrl_wb_Mem2Reg_i;
	wire ex_ctrl_mem_read_i;
	wire ex_ctrl_mem_write_i;
	wire ex_ctrl_ex_AluSrc_i; 
	wire[`CtrlAluOpBus] ex_ctrl_ex_AluOp_i;

    wire[`RegAddrBus] ex_reg1_addr_i;
	wire[`RegAddrBus] ex_reg2_addr_i;
	wire[1:0] ex_alu_mux1;
	wire[1:0] ex_alu_mux2;
	wire[`RegBus] ex_reg1_data;
	wire[`RegBus] ex_reg2_data;
	
	wire[`RegBus] ex_reg1_data_i;
	wire[`RegBus] ex_reg2_data_i;
	wire[`ImmBus] ex_imm_data_i;
	wire ex_alu_lr_i;
	wire[`AluOpBus] ex_alu_op_i;
	wire[`RegAddrBus] ex_write_addr_i;

	// uart detection
	wire ex_ctrl_hold;
	wire ex_ctrl_detection_o;

	wire[`RegBus] ex_alu_result_o;
	wire[`RegBus] ex_mem_write_data_o;

	wire[`AluCtrlBus] alu_ctrl;
	
	wire ex_ctrl_wb_RegWrite_o;
    wire ex_ctrl_wb_Mem2Reg_o;
    wire ex_ctrl_mem_read_o;
    wire ex_ctrl_mem_write_o;
    wire[`RegAddrBus] ex_write_addr_o;
    wire[2:0] ex_mem_op_o;

	assign ex_ctrl_wb_RegWrite_o = ex_ctrl_wb_RegWrite_i;
	assign ex_ctrl_wb_Mem2Reg_o = ex_ctrl_wb_Mem2Reg_i;
	assign ex_ctrl_mem_read_o = ex_ctrl_mem_read_i;
	assign ex_ctrl_mem_write_o = ex_ctrl_mem_write_i;
	assign ex_write_addr_o = ex_write_addr_i;
	assign ex_mem_op_o = ex_alu_op_i;

	// mem
	wire mem_ctrl_detection_i;
	wire mem_ctrl_wb_RegWrite_i;
	wire mem_ctrl_wb_Mem2Reg_i;
	wire mem_ctrl_mem_read_i;
	wire mem_ctrl_mem_write_i;
	wire[`RegBus] mem_alu_result_i;
	wire[`RegBus] mem_mem_write_data_i;
	wire[`RegAddrBus] mem_write_addr_i;
	wire[2:0] mem_mem_op_i;	
	
	wire mem_finish_o;
    wire mem_ctrl_wb_RegWrite_o;
    wire mem_ctrl_wb_Mem2Reg_o;
    wire[`RegAddrBus] mem_write_addr_o;
	wire[`RegBus] mem_mem_read_data_o;
	wire[`RegBus] mem_alu_result_o;

	assign mem_ctrl_wb_RegWrite_o = mem_ctrl_wb_RegWrite_i;
	assign mem_ctrl_wb_Mem2Reg_o = mem_ctrl_wb_Mem2Reg_i;
	assign mem_write_addr_o = mem_write_addr_i;

	// mem_wb
	wire mem_wb_hold;
	
	// wb
	wire wb_ctrl_wb_RegWrite_i;
	wire wb_ctrl_wb_Mem2Reg_i;
	wire[`RegBus] wb_mem_read_data_i;
	wire[`RegBus] wb_alu_result_i;
	wire[`RegAddrBus] wb_write_addr_i;
	
	wire[`RegBus] wb_write_data_o;

	assign pc_hold_i = id_ctrl_hold | ex_ctrl_hold | mem_ctrl_ram;
	assign debug = {ctrl_pc_src, pc[16:2]};
	pc_reg pc_reg0(
		.clk(clk),
		.rst(rst),

		.pc_hold_i(pc_hold_i),
		.ctrl_pc_src_i(ctrl_pc_src),
		.pc_i(next_pc_i),
		.branch_pc_i(branch_pc),

		.pc_o(pc),
		.rom_ce_o(rom_ce_n)
	);

	assign ctrl_if_flush = ctrl_pc_src | mem_ctrl_ram;
	assign if_id_hold = id_ctrl_hold | ex_ctrl_hold;
	if_id if_id0(
		.clk(clk),
		.rst(rst),

		.ctrl_if_flush(ctrl_if_flush),
		.if_id_hold(if_id_hold),
		.if_pc(pc),
		.if_inst(rom_data),

		.id_pc(id_pc_i),
		.id_inst(id_inst_i)
	);

	detection detection0(
		.inst_i(id_inst_i),
		.ex_ctrl_mem_read_i(ex_ctrl_mem_read_o),
		.ex_ctrl_wb_Mem2Reg_i(ex_ctrl_wb_Mem2Reg_o),
		.ex_ctrl_wb_RegWrite_i(ex_ctrl_wb_RegWrite_o),
		.ex_write_addr_i(ex_write_addr_o),

		.mem_ctrl_mem_read_i(mem_ctrl_mem_read_i),
		.mem_ctrl_wb_Mem2Reg_i(mem_ctrl_wb_Mem2Reg_o),
		.mem_write_addr_i(mem_write_addr_o),

		.ctrl_detection_o(id_ctrl_hold)
	);

	control ctrl0(
	    .ctrl_mux_i(id_ctrl_hold),
		.inst_i(id_inst_i),

		.ctrl_wb_RegWrite_o(id_ctrl_wb_RegWrite_o),
		.ctrl_wb_Mem2Reg_o(id_ctrl_wb_Mem2Reg_o),
		.ctrl_mem_read_o(id_ctrl_mem_read_o),
		.ctrl_mem_write_o(id_ctrl_mem_write_o),
		.ctrl_ex_AluSrc_o(id_ctrl_ex_AluSrc_o),
		.ctrl_ex_AluOp_o(id_ctrl_ex_AluOp_o)
	);

	id id0(
		.rst(rst),

        .pc_i(id_pc_i),
		.inst_i(id_inst_i),

		.reg1_data_i(id_reg1_data_i),
		.reg2_data_i(id_reg2_data_i),

		.reg1_data_o(id_reg1_data_o),
		.reg2_data_o(id_reg2_data_o),
		.reg1_addr_o(id_reg1_addr_o),
		.reg2_addr_o(id_reg2_addr_o),

		.imm_data_o(id_imm_data_o),
		.branch_imm_o(branch_imm),

		.alu_lr_o(id_alu_lr_o),
		.alu_op_o(id_alu_op_o),

		.write_addr_o(id_write_addr_o)
	);

	regfile regfile0(
		.clk(clk),
		.rst(rst),

		.read_addr_1(id_reg1_addr_o),
		.read_data_1(id_reg1_data_i),
		.read_addr_2(id_reg2_addr_o),
		.read_data_2(id_reg2_data_i),
		.write_ce(wb_ctrl_wb_RegWrite_i),
		.write_addr(wb_write_addr_i),
		.write_data(wb_write_data_o)
	);

	forward control_forward(
		.id_reg1_addr_i(id_reg1_addr_i),
		.id_reg2_addr_i(id_reg2_addr_i),
		
		.mem_ctrl_wb_RegWrite_i(mem_ctrl_wb_RegWrite_o),
		.mem_write_addr_i(mem_write_addr_o),
		
		.wb_ctrl_wb_RegWrite_i(wb_ctrl_wb_RegWrite_i),
		.wb_write_addr_i(wb_write_addr_i),
		
		.alu_mux1_o(id_alu_mux1),
		.alu_mux2_o(id_alu_mux2)
	);

	data_mux id_data_mux(
		.id_reg1_data_i(id_reg1_data_o),
		.mem_reg1_data_i(mem_alu_result_i),
		.wb_reg1_data_i(wb_write_data_o),

		.id_reg2_data_i(id_reg2_data_o),
		.mem_reg2_data_i(mem_alu_result_i),
		.wb_reg2_data_i(wb_write_data_o),

		.alu_mux1_i(id_alu_mux1),
		.alu_mux2_i(id_alu_mux2),

		.reg1_data_o(id_reg1_data),
		.reg2_data_o(id_reg2_data)
	);

	compare compare0(
		.inst_i(id_inst_i),
		.reg1_data_i(id_reg1_data),
		.reg2_data_i(id_reg2_data),

		.pc_i(id_pc_i),
		.branch_imm_i(branch_imm),
		.branch_pc_o(branch_pc),

		.ctrl_pc_src_o(ctrl_pc_src)
	);

	
	assign id_ex_flush = ex_ctrl_hold;
	id_ex id_ex0(
		.clk(clk),
		.rst(rst),

		.id_ex_flush(id_ex_flush),

		.ctrl_wb_RegWrite_i(id_ctrl_wb_RegWrite_o),
		.ctrl_wb_Mem2Reg_i(id_ctrl_wb_Mem2Reg_o),
		.ctrl_mem_read_i(id_ctrl_mem_read_o),
		.ctrl_mem_write_i(id_ctrl_mem_write_o),
		.ctrl_ex_AluSrc_i(id_ctrl_ex_AluSrc_o),
		.ctrl_ex_AluOp_i(id_ctrl_ex_AluOp_o),

		.reg1_data_i(id_reg1_data_o),
		.reg2_data_i(id_reg2_data_o),
		
		.reg1_addr_i(id_reg1_addr_i),
		.reg2_addr_i(id_reg2_addr_i),

		.imm_data_i(id_imm_data_o),

		.alu_lr_i(id_alu_lr_o),
		.alu_op_i(id_alu_op_o),

		.write_addr_i(id_write_addr_o),

		.ctrl_wb_RegWrite_o(ex_ctrl_wb_RegWrite_i),
		.ctrl_wb_Mem2Reg_o(ex_ctrl_wb_Mem2Reg_i),
		.ctrl_mem_read_o(ex_ctrl_mem_read_i),
		.ctrl_mem_write_o(ex_ctrl_mem_write_i),
		.ctrl_ex_AluSrc_o(ex_ctrl_ex_AluSrc_i),
		.ctrl_ex_AluOp_o(ex_ctrl_ex_AluOp_i),

		.reg1_data_o(ex_reg1_data_i),
		.reg2_data_o(ex_reg2_data_i),
		
		.reg1_addr_o(ex_reg1_addr_i),
        .reg2_addr_o(ex_reg2_addr_i),

		.imm_data_o(ex_imm_data_i),

		.alu_lr_o(ex_alu_lr_i),
		.alu_op_o(ex_alu_op_i),

		.write_addr_o(ex_write_addr_i)
	);

	alu_control alu_ctrl0(
		.rst(rst),

		.ctrl_ex_AluOp_i(ex_ctrl_ex_AluOp_i),
		.alu_lr_i(ex_alu_lr_i),
		.alu_op_i(ex_alu_op_i),
		.alu_ctrl_o(alu_ctrl)
	);

	forward ex_forward(
		.id_reg1_addr_i(ex_reg1_addr_i),
		.id_reg2_addr_i(ex_reg2_addr_i),
		
		.mem_ctrl_wb_RegWrite_i(mem_ctrl_wb_RegWrite_o),
		.mem_write_addr_i(mem_write_addr_o),
		
		.wb_ctrl_wb_RegWrite_i(wb_ctrl_wb_RegWrite_i),
		.wb_write_addr_i(wb_write_addr_i),
		
		.alu_mux1_o(ex_alu_mux1),
		.alu_mux2_o(ex_alu_mux2)
	);

	data_mux ex_data_mux(
		.id_reg1_data_i(ex_reg1_data_i),
		.mem_reg1_data_i(mem_alu_result_i),
		.wb_reg1_data_i(wb_write_data_o),

		.id_reg2_data_i(ex_reg2_data_i),
		.mem_reg2_data_i(mem_alu_result_i),
		.wb_reg2_data_i(wb_write_data_o),

		.alu_mux1_i(ex_alu_mux1),
		.alu_mux2_i(ex_alu_mux2),

		.reg1_data_o(ex_reg1_data),
		.reg2_data_o(ex_reg2_data)
	);

	ex ex0(
		.ctrl_ex_AluSrc_i(ex_ctrl_ex_AluSrc_i),

		.alu_ctrl_i(alu_ctrl),
        
		.reg1_data_i(ex_reg1_data),
		.reg2_data_i(ex_reg2_data),

		.imm_data_i(ex_imm_data_i),

		.alu_result_o(ex_alu_result_o),

		.mem_write_data_o(ex_mem_write_data_o)
	);

	uart_detection uart_detection0(
		.ctrl_mem_read_i(ex_ctrl_mem_read_i),
		.ctrl_mem_write_i(ex_ctrl_mem_write_i),
		.alu_result_i(ex_alu_result_o),
		.mem_ctrl_detection_i(mem_ctrl_detection_i),

		.ex_ctrl_detection_o(ex_ctrl_detection_o),
		.ctrl_detection_o(ex_ctrl_hold)
	);

	wire ex_mem_hold;
	assign ex_mem_hold = mem_finish_o;

	ex_mem ex_mem0(
		.clk(clk),
		.rst(rst),

		.ex_mem_hold(ex_mem_hold),
	
		.ctrl_detection_i(ex_ctrl_detection_o),
		.ctrl_wb_RegWrite_i(ex_ctrl_wb_RegWrite_o),
		.ctrl_wb_Mem2Reg_i(ex_ctrl_wb_Mem2Reg_o),
		.ctrl_mem_read_i(ex_ctrl_mem_read_o),
		.ctrl_mem_write_i(ex_ctrl_mem_write_o),

		.alu_result_i(ex_alu_result_o),

		.mem_write_data_i(ex_mem_write_data_o),

		.write_addr_i(ex_write_addr_o),

		.mem_op_i(ex_mem_op_o),

		// output 
		.ctrl_detection_o(mem_ctrl_detection_i),
		.ctrl_wb_RegWrite_o(mem_ctrl_wb_RegWrite_i),
		.ctrl_wb_Mem2Reg_o(mem_ctrl_wb_Mem2Reg_i),
		.ctrl_mem_read_o(mem_ctrl_mem_read_i),
		.ctrl_mem_write_o(mem_ctrl_mem_write_i),

		.alu_result_o(mem_alu_result_i),

		.mem_write_data_o(mem_mem_write_data_i),

		.write_addr_o(mem_write_addr_i),

		.mem_op_o(mem_mem_op_i)
	);

	wire ram_finish;
	wire sign_finish;
	wire uart_finish;
	
	wire mem_ram_use;
	wire mem_sign_use;
	wire mem_uart_use;

	wire[`RegBus] mem_data_bus;
	wire[`RamAddrBus] mem_ram_addr;
	wire[3:0] mem_ram_be_n;
	wire mem_ram_ce_n;
	wire mem_ram_oe_n;
	wire mem_ram_we_n;

	wire mem_uart_rdn;
	wire mem_uart_wrn;

	mem mem0(
		.ctrl_detection_i(mem_ctrl_detection_i),
		.ctrl_mem_read_i(mem_ctrl_mem_read_i),
		.ctrl_mem_write_i(mem_ctrl_mem_write_i),

		.alu_result_i(mem_alu_result_i),

		.mem_write_data_i(mem_mem_write_data_i),

		.mem_op_i(mem_mem_op_i),
		.mem_read_data_i(mem_data_bus),
		.mem_write_data_o(mem_data_bus),

		.ram_finish_i(ram_finish),
		.sign_finish_i(sign_finish),
		.uart_finish_i(uart_finish),
		.mem_finish_o(mem_finish_o),

		.mem_ram_use_o(mem_ram_use),
		.mem_sign_use_o(mem_sign_use),
		.mem_uart_use_o(mem_uart_use),

		//sram
		.mem_ram_addr_o(mem_ram_addr),
		.mem_ram_be_n_o(mem_ram_be_n),
		.mem_ram_ce_n_o(mem_ram_ce_n),
		.mem_ram_oe_n_o(mem_ram_oe_n),
		.mem_ram_we_n_o(mem_ram_we_n),

		// uart
		.mem_uart_rdn_o(mem_uart_rdn),
		.mem_uart_wrn_o(mem_uart_wrn),

		.mem_read_data_o(mem_mem_read_data_o),

		.alu_result_o(mem_alu_result_o)
	);

	sram_ctrl sram_ctrl0(
		.rst(mem_ram_use),
		.clk(clk),
		
		.ram_write_data_i(mem_data_bus),
		.ram_addr_i(mem_ram_addr),
		.ram_be_n_i(mem_ram_be_n),
		.ram_ce_n_i(mem_ram_ce_n),
		.ram_oe_n_i(mem_ram_oe_n),
		.ram_we_n_i(mem_ram_we_n),

		.ram_read_data_i(ram_data),
		.ram_read_data_o(mem_data_bus),
		

		.ram_write_data_o(ram_data),
		.ram_addr_o(ram_addr),
		.ram_be_n_o(ram_be_n),
		.ram_ce_n_o(ram_ce_n),
		.ram_oe_n_o(ram_oe_n),
		.ram_we_n_o(ram_we_n),

		.ram_finish_o(ram_finish)
	);

	sign_ctrl sign_ctrl0(
		.rst(mem_sign_use),
		.clk(clk),

		.tsre_i(uart_tsre),
		.data_ready_i(uart_data_ready),

		.sign_data_o(mem_data_bus),
		.sign_finish_o(sign_finish)
	);

	uart_ctrl uart_ctrl0(
	    //.debug(debug),
		.rst(mem_uart_use),
		.clk(clk_11M),

		.uart_write_data_i(mem_data_bus),
		.data_ready_i(uart_data_ready),
		.rdn_i(mem_uart_rdn),
		.tbre_i(uart_tbre),
		.tsre_i(uart_tsre),
		.wrn_i(mem_uart_wrn),
		
		.uart_read_data_i(uart_data),
		.uart_read_data_o(mem_data_bus),

		.uart_write_data_o(uart_data),
		.rdn_o(uart_rdn),
		.wrn_o(uart_wrn),
		.uart_finish_o(uart_finish),

		.mem_ctrl_ram(mem_ctrl_ram)
	);

	assign mem_wb_hold = mem_finish_o;
	mem_wb mem_wb0(
		.clk(clk),
		.rst(rst),

		.mem_wb_hold(mem_wb_hold),

		.ctrl_wb_RegWrite_i(mem_ctrl_wb_RegWrite_o),
		.ctrl_wb_Mem2Reg_i(mem_ctrl_wb_Mem2Reg_o),

		.mem_read_data_i(mem_mem_read_data_o),

		.alu_result_i(mem_alu_result_o),

		.write_addr_i(mem_write_addr_o),

		.ctrl_wb_RegWrite_o(wb_ctrl_wb_RegWrite_i),
		.ctrl_wb_Mem2Reg_o(wb_ctrl_wb_Mem2Reg_i),

		.mem_read_data_o(wb_mem_read_data_i),

		.alu_result_o(wb_alu_result_i),

		.write_addr_o(wb_write_addr_i)
	); 


	wb wb0(
		.rst(rst),

		.ctrl_wb_Mem2Reg_i(wb_ctrl_wb_Mem2Reg_i),
		.mem_read_data_i(wb_mem_read_data_i),
		.alu_result_i(wb_alu_result_i),

		.write_data_o(wb_write_data_o)
	);

endmodule