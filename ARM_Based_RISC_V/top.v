module top(
    input  CLK100MHZ,
    input  [3:0] btn,
    input  [3:0] sw,
    output [3:0] led,
    output led0_r, led0_g, led0_b,
    output led1_r, led1_g, led1_b
);

// =====================
// SIGNALS
// =====================
wire reset = btn[0];

// =====================
// BUTTON DEBOUNCE (btn[1] = step)
// =====================
// ~20ms debounce at 100MHz = 2,000,000 cycles
reg [20:0] db_count;
reg db_stable;      // debounced button level
reg db_prev;        // previous stable level
wire step_pulse;    // single pulse on rising edge

always @(posedge CLK100MHZ or posedge reset) begin
    if (reset) begin
        db_count  <= 0;
        db_stable <= 0;
        db_prev   <= 0;
    end else begin
        if (btn[1] == db_stable) begin
            db_count <= 0;          // input matches stable: reset counter
        end else begin
            db_count <= db_count + 1;
            if (db_count == 21'd1_999_999) begin
                db_stable <= btn[1]; // stable for 20ms: accept new level
                db_count  <= 0;
            end
        end
        db_prev <= db_stable;
    end
end

// Rising edge of debounced signal = one step pulse
assign step_pulse = db_stable & ~db_prev;

// =====================
// CPU CLOCK = step pulse
// =====================
wire cpu_clk = step_pulse;

// =====================
// CPU + MEMORY WIRES
// =====================
wire [31:0] PC, Instr, ReadData;
wire [31:0] WriteData;
wire [31:0] ALUResult;
wire MemWrite;

// =====================
// CPU INSTANCE
// =====================
cpu cpu(
    .clk       (cpu_clk),
    .reset     (reset),
    .PC        (PC),
    .Instr     (Instr),
    .MemWrite  (MemWrite),
    .ALUResult (ALUResult),
    .WriteData (WriteData),
    .ReadData  (ReadData)
);

// =====================
// INSTRUCTION MEMORY
// =====================
imem imem(
    .a  (PC),
    .rd (Instr)
);

// =====================
// DATA MEMORY
// =====================
dmem dmem(
    .clk (cpu_clk),
    .we  (MemWrite),
    .a   (ALUResult),
    .wd  (WriteData),
    .rd  (ReadData)
);

// =====================
// SWITCH-BASED DISPLAY
// sw[1:0]:
//   00 → PC[3:0]
//   01 → ALUResult[3:0]
//   10 → Instr[3:0]
//   11 → WriteData[3:0]
// =====================
reg [3:0] selected_data;
always @(*) begin
    case (sw[1:0])
        2'b00: selected_data = PC[3:0];
        2'b01: selected_data = ALUResult[3:0];
        2'b10: selected_data = Instr[3:0];
        2'b11: selected_data = WriteData[3:0];
    endcase
end

// =====================
// DEBUG OUTPUTS
// =====================
assign led    = selected_data;

assign led0_r = ALUResult[0];
assign led0_g = ALUResult[1];
assign led0_b = ALUResult[2];

assign led1_r = Instr[0];
assign led1_g = Instr[1];
assign led1_b = Instr[2];

endmodule
