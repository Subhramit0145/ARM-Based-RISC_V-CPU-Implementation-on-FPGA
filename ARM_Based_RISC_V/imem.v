module imem(
    input  [31:0] a,
    output [31:0] rd
);
    reg [31:0] mem [0:63];

    integer i;
    initial begin
        // Initialize all to NOP (MOV R0, R0 = E1A00000)
        for (i = 0; i < 64; i = i + 1)
            mem[i] = 32'hE1A00000;

        // Your memfile.mem instructions loaded explicitly
        mem[ 0] = 32'hE04F000F;
        mem[ 1] = 32'hE2802005;
        mem[ 2] = 32'hE280300C;
        mem[ 3] = 32'hE2437009;
        mem[ 4] = 32'hE1874002;
        mem[ 5] = 32'hE0035004;
        mem[ 6] = 32'hE0855004;
        mem[ 7] = 32'hE0558007;
        mem[ 8] = 32'h0A00000C;
        mem[ 9] = 32'hE0538004;
        mem[10] = 32'hAA000000;
        mem[11] = 32'hE2805000;
        mem[12] = 32'hE0578002;
        mem[13] = 32'hB2857001;
        mem[14] = 32'hE0477002;
        mem[15] = 32'hE5837054;
        mem[16] = 32'hE5902060;
        mem[17] = 32'hE08FF000;
        mem[18] = 32'hE280200E;
        mem[19] = 32'hEA000001;
        mem[20] = 32'hE280200D;
        mem[21] = 32'hE280200A;
        mem[22] = 32'hE5802054;
        // mem[23] to mem[63] remain NOP
    end

    // Word-aligned access: PC byte address → word index
    assign rd = mem[a[31:2]];

endmodule
