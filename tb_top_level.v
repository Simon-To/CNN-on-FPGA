`timescale 1ns/1ps

module tb_top_level_cordic_constants;

  // Declare clock and address signals.
  reg clk;
  reg [3:0] addr;
  
  // Wires for the outputs from the top level module.
  wire [15:0] atanh_const;
  wire [15:0] scale_const;
  
  // Instantiate the top-level module.
  top_level_cordic_constants uut (
    .clk(clk),
    .addr(addr),
    .atanh_const(atanh_const),
    .scale_const(scale_const)
  );
  
  // Generate a clock signal with a period of 10 ns.
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // Toggle clock every 5 ns.
  end
  
  // Stimulus: cycle through addresses to read the constants.
  integer i;
  initial begin
    // Start with address 0.
    addr = 0;
    #10; // Wait a couple of clock cycles for initialization.
    
    // Iterate over the valid address range (here, 0 to 9 for DEPTH=10).
    for (i = 0; i < 10; i = i + 1) begin
      addr = i;
      #10; // Wait to allow the ROM output to update.
    end
    
    #20; // Wait a bit before finishing the simulation.
    $finish;
  end
  
  // Monitor output values.
  initial begin
    $monitor("Time: %0t, addr: %0d, atanh_const: 0x%0h, scale_const: 0x%0h",
              $time, addr, atanh_const, scale_const);
  end

endmodule
