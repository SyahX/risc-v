`timescale 1ns / 1ps

`include "defines.v"

module inst_rom(
    input wire ce,
    input wire[`InstAddrBus] addr,
    output reg[`InstBus] inst
);
    reg[`InstBus] inst_mem[0:`InstMemNum-1];
    initial $readmemh ( "/home/syah/code/risc-v/test/data/branch.data", inst_mem );
    always @ (*) begin
        if (ce == `DeAsserted) begin
            inst <= `ZeroWord;
        end else begin
            inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
        end
    end
endmodule
