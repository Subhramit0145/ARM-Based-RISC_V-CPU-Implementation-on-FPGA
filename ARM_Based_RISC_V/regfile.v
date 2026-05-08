`timescale 1ns / 1ps
module regfile (
    input         clk,
    input         we3,
    input         reset,        // ← ADDED: reset clears all registers
    input  [3:0]  ra1, ra2, wa3,
    input  [31:0] wd3, r15,
    output [31:0] rd1, rd2
);
    reg [31:0] rf[14:0];
    integer i;

    // Synchronous reset clears all registers
    // Also supports normal register write
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 15; i = i + 1)
                rf[i] <= 32'b0;
        end else if (we3 && wa3 != 4'b1111) begin
            rf[wa3] <= wd3;
        end
    end

    // Combinational reads - R15 returns PC+8 passed in from datapath
    assign rd1 = (ra1 == 4'b1111) ? r15 : rf[ra1];
    assign rd2 = (ra2 == 4'b1111) ? r15 : rf[ra2];

endmodule
