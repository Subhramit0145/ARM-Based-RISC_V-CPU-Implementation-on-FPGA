
module dmem(input  clk, we,
            input  [31:0] a, wd,
            output [31:0] rd);   // <-- remove 'reg' here

    reg [31:0] RAM[63:0];

    //DD THIS BLOCK HERE (right after RAM declaration)
    integer i;
    initial begin
        for (i = 0; i < 64; i = i + 1)
            RAM[i] = i;   // or use 32'b0 if you want all zeros
    end

    // READ
    assign rd = RAM[a[31:2]]; 

    // WRITE
    always @(posedge clk)
        if (we)
            RAM[a[31:2]] <= wd;

endmodule

