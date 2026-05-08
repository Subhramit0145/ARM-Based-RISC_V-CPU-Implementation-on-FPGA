`timescale 1ns / 1ps
module datapath(
    input         clk, reset,
    input  [1:0]  RegSrc,
    input         RegWrite,
    input  [1:0]  ImmSrc,
    input         ALUSrc,
    input  [1:0]  ALUControl,
    input         MemtoReg,
    input         PCSrc,
    output [3:0]  ALUFlags,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] ALUResult,
    output [31:0] WriteData,
    input  [31:0] ReadData
);
    wire [31:0] PCNext, PCPlus4, PCPlus8;
    wire [31:0] ExtImm, SrcA, SrcB, Result;
    wire [3:0]  RA1, RA2;

    // PC logic
    mux2 #(32) pcmux(PCPlus4, Result, PCSrc, PCNext);
    flopr #(32) pcreg(clk, reset, PCNext, PC);
    adder pcadd1(PC,       32'd4, PCPlus4);
    adder pcadd2(PCPlus4,  32'd4, PCPlus8);

    // Register file address muxes
    mux2 #(4) ra1mux(Instr[19:16], 4'b1111,      RegSrc[0], RA1);
    mux2 #(4) ra2mux(Instr[3:0],   Instr[15:12], RegSrc[1], RA2);

    // Register file - reset port added
    regfile rf(
        .clk   (clk),
        .we3   (RegWrite),
        .reset (reset),         // ← pass reset through
        .ra1   (RA1),
        .ra2   (RA2),
        .wa3   (Instr[15:12]),
        .wd3   (Result),
        .r15   (PCPlus8),
        .rd1   (SrcA),
        .rd2   (WriteData)
    );

    // Write-back mux
    mux2 #(32) resmux(ALUResult, ReadData, MemtoReg, Result);

    // Immediate extension
    extend ext(Instr[23:0], ImmSrc, ExtImm);

    // ALU source mux
    mux2 #(32) srcbmux(WriteData, ExtImm, ALUSrc, SrcB);

    // ALU
    alu alu(SrcA, SrcB, ALUControl, ALUResult, ALUFlags);

endmodule
