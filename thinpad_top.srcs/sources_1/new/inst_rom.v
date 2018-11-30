`timescale 1ns / 1ps

`include "defines.v"

module inst_rom(
    input wire ce,
    input wire[19:0] addr,
    output reg[`InstBus] inst
);
    reg[`InstBus] inst_mem[0:1048575];
    initial $readmemh ( "/home/syah/code/risc-v/test/data/test.data", inst_mem );
    always @ (*) begin
        if (ce == `Asserted) begin
            inst <= `ZeroWord;
        end else begin
            inst <= inst_mem[addr];
        end
    end
endmodule
