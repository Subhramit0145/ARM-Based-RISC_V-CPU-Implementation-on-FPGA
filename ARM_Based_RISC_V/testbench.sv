`timescale 1ns / 1ps
module testbench();

  reg clk;
  reg reset;

  top dut(clk, reset);

  //CORRECT INITIALIZATION
  initial begin

    clk = 0;        // FIX: initialize clock
    reset = 1;

    #10 reset = 0;
  end

  //CLOCK GENERATION
  always #5 clk = ~clk;

  //TEST CHECK
  initial begin 
    #10000
    if (dut.cpu.dp.rf.rf[5] === 32'd11) begin
      $display("Test Passed: R5 contains 11");
    end else begin
      $display("Test Failed: R5 = %d, expected 11", dut.cpu.dp.rf.rf[5]);
    end
    $finish;
  end
  endmodule
