`timescale 1ns / 1ps
module alu(
    input  [31:0] SrcA,
    input  [31:0] SrcB,
    input  [1:0]  ALUControl,
    output reg [31:0] ALUResult,
    output reg [3:0]  ALUFlag
);
    reg Negative, Zero, Carry, Overflow;
    reg [32:0] sum;   // 33-bit for carry extraction

    always @(*) begin
        Carry    = 0;
        Overflow = 0;

        case (ALUControl)
            2'b00: begin // ADD
                sum      = {1'b0, SrcA} + {1'b0, SrcB};  // 33-bit ADD
                ALUResult = sum[31:0];
                Carry     = sum[32];
                Overflow  = (~SrcA[31] & ~SrcB[31] &  ALUResult[31])
                          | ( SrcA[31] &  SrcB[31] & ~ALUResult[31]);
            end
            2'b01: begin // SUB
                // *** FIX: use 33-bit subtraction so Carry = NOT borrow ***
                // ARM C flag for SUB = 1 when no borrow (SrcA >= SrcB unsigned)
                sum       = {1'b0, SrcA} - {1'b0, SrcB};  // 33-bit SUB
                ALUResult = sum[31:0];
                Carry     = sum[32];   // sum[32]=1 means no borrow
                // Note: for SUB, ARM Carry = NOT borrow.
                // {1'b0,A}-{1'b0,B}: if A>=B, result is positive 33-bit → sum[32]=0
                // That gives Carry=0 which is WRONG for ARM. Need to invert:
                Carry     = ~sum[32];  // invert: Carry=1 when A>=B (no borrow)
                Overflow  = ( SrcA[31] & ~SrcB[31] & ~ALUResult[31])
                          | (~SrcA[31] &  SrcB[31] &  ALUResult[31]);
            end
            2'b10: begin // AND
                ALUResult = SrcA & SrcB;
            end
            2'b11: begin // OR
                ALUResult = SrcA | SrcB;
            end
        endcase

        Zero     = (ALUResult == 32'b0);
        Negative = ALUResult[31];
        ALUFlag  = {Negative, Zero, Carry, Overflow};
    end

endmodule
