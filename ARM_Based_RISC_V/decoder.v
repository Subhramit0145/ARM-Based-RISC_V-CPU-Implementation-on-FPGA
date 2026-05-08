module decoder(
    input  [1:0] Op,
    input  [5:0] Funct,
    input  [3:0] Rd,
    output reg [1:0] FlagW,
    output reg       PCS, RegW, MemW,
    output reg       MemtoReg, ALUSrc,
    output reg [1:0] ImmSrc, RegSrc, ALUControl
);
    reg Branch, ALUOp;

    always @(*) begin
        Branch   = 0;
        MemtoReg = 0;
        MemW     = 0;
        ALUSrc   = 0;
        ImmSrc   = 2'b00;
        RegW     = 0;
        RegSrc   = 2'b00;
        ALUOp    = 0;

        case (Op)
            2'b00: begin            // Data Processing
                RegW   = 1;
                ALUOp  = 1;
                ALUSrc = Funct[5];
            end
            2'b01: begin            // Memory
                ALUSrc = 1;
                ImmSrc = 2'b01;
                if (Funct[0]) begin // LDR
                    RegW     = 1;
                    MemtoReg = 1;
                end else begin      // STR
                    MemW   = 1;
                    RegSrc = 2'b10;
                end
            end
            2'b10: begin            // Branch
                Branch = 1;
                ALUSrc = 1;         // FIX: use ExtImm as SrcB
                ImmSrc = 2'b10;
                RegSrc = 2'b01;     // FIX: RA1=R15=PC+8 as SrcA
            end
        endcase

        PCS = ((Rd == 4'b1111) & RegW) | Branch;
    end

    always @(*) begin
        if (ALUOp) begin
            case (Funct[4:1])
                4'b0100: ALUControl = 2'b00;
                4'b0010: ALUControl = 2'b01;
                4'b0000: ALUControl = 2'b10;
                4'b1100: ALUControl = 2'b11;
                default: ALUControl = 2'b00;
            endcase
            FlagW[1] = Funct[0];
            FlagW[0] = Funct[0] & (ALUControl == 2'b00 || ALUControl == 2'b01);
        end else begin
            ALUControl = 2'b00;
            FlagW      = 2'b00;
        end
    end

endmodule
