module alu(
    input [31:0] SrcA,   // 32-bit input A
    input [31:0] SrcB,   // 32-bit input B
    input [1:0] ALUControl, //ALU control signal to select operation
    output reg[31:0] ALUResult,
  
//     output reg Zero,
//     output reg Negative,
//     output reg Overflow,
//     output reg Carry
  	output reg [3:0] ALUFlag
    );
    
  
  	reg Negative,Zero,Carry,Overflow;
    
    always @(*) begin
        case(ALUControl)
            2'b00 : begin //AND
                {Carry, ALUResult} = SrcA + SrcB; // Concatenation to include carry out
             	 //Overflow=Carry;
            	Overflow = ((SrcA[31] == SrcB[31]) && (ALUResult[31] != SrcA[31]));
            end
            2'b01 : begin //OR
                {Carry, ALUResult} = SrcA - SrcB;
             	 //Overflow=Carry;
              	Overflow =((SrcA[31] != SrcB[31]) && (ALUResult[31] != SrcA[31])); 
            end
            2'b10 : begin //ADD
                ALUResult = SrcA & SrcB;
                Carry = 0;
                Overflow = 0;
            end
            2'b11 : begin //SUB
                ALUResult = SrcA | SrcB;
                Carry = 0;
                Overflow = 0;
            end
            default: begin
                ALUResult = 32'b0;
                Carry = 0;
                Overflow = 0;
            end
        endcase
    end
    
    assign Zero = (ALUResult == 32'b0) ? 1'b1 : 1'b0; 
    assign Negative = ALUResult[31];
  	assign ALUFlag={Negative,Zero,Carry,Overflow};


endmodule

