`timescale 1ns / 1ps


module clock_new(
    input wire clk_50M,
    input wire reset_btn,
    output reg clk_10M
    );
    reg[3:0] count = 4'h0;

    initial @(reset_btn)
    begin
        count <= 0;
        clk_10M <= `DeAsserted;
    end

    always @(posedge(clk_50M))
    begin
        if(count == 4'h1) begin
            clk_10M <= ~clk_10M;
            count <= 0;
        end
        else begin
            clk_10M <= clk_10M;
            count <= count + 1;
        end
    end
endmodule
