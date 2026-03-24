module decoder(
    input [1:0] Op,
    input [5:0] Funct,
    input [3:0] Rd,
    output reg [1:0] FlagW,
    output reg PCS,RegW,MemW,
    output reg MemtoReg,ALUSrc,
    output reg [1:0] ImmSrc, RegSrc, ALUControl
    );
    
//internal Wires
    reg Branch, ALUOp;
    reg [9:0] controls;
  
  	assign {Branch, MemtoReg, MemW, ALUSrc, ImmSrc, RegW, RegSrc, ALUOp} = controls;
    
//decoder    
    //putting 0 inplace of x as we are using casex
    always @(*) begin
        casex(Op)
            2'b00 : begin
              if(Funct[5]) controls = 10'b0001001001; //data processing imm   
                        else controls = 10'b0000001001; // data processing register
                    end
            2'b01 : begin
                        if(Funct[0]) controls = 10'b0101011000;//LDR
                        else controls = 10'b0011010100;//STR
                    end
            2'b10 : controls = 10'b1001100010; // B
            default: controls = 10'bx;
        
        endcase   
        
    end
    
//alu decoder    
    always @(*) begin
        if(ALUOp) begin
            case(Funct[4:1])
                4'b0100 : ALUControl = 2'b00;//ADD
                4'b0010 : ALUControl = 2'b01;//SUB
                4'b0000 : ALUControl = 2'b10;//AND
                4'b1100 : ALUControl = 2'b11;//OR
                default : ALUControl = 2'bx;
            endcase
            
            FlagW[1] = Funct[0];
            FlagW[0] = Funct[0] & (ALUControl == 2'b00 | ALUControl == 2'b01);
        end
        else begin
            ALUControl = 2'b00;
            FlagW = 2'b00;
        end
    end
    
    assign PCS = ((Rd == 4'b1111) & RegW) | Branch;
    
endmodule
