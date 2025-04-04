`timescale 1ns/1ps
module tanh_initializer_tb;

  // Parameter for the design under test.
  parameter WIDTH = 32;
  
  // Inputs to the DUT.
  reg [WIDTH-1:0] conv_result;
  reg [WIDTH-1:0] scaling_factor;
  
  // Outputs from the DUT.
  wire [WIDTH-1:0] init_x;     // Q4.(WIDTH-4) fixed-point reciprocal
  wire [WIDTH-1:0] init_y;     // Should always be zero
  wire [WIDTH-1:0] init_angle; // Just passes through conv_result

  // Instantiate the module under test.
  tanh_initializer #(
    .WIDTH(WIDTH)
  ) dut (
    .conv_result(conv_result),
    .scaling_factor(scaling_factor),
    .init_x(init_x),
    .init_y(init_y),
    .init_angle(init_angle)
  );
  
  // Test stimulus.
  initial begin
    $display("tanh_initializer Testbench Starting...");
    
    // Test Case 1:
    // scaling_factor nearly 1.0 in U0.32 format.
    // For U0.32, 1.0 is ideally 2^32, but since we use 32 bits the maximum is 0xFFFFFFFF,
    // which represents slightly less than 1.0.
    conv_result     = 32'h12345678;
    scaling_factor  = 32'hFFFFFFFF; 
    #1;
    $display("Test 1:");
    $display("  conv_result    = 0x%h", conv_result);
    $display("  scaling_factor = 0x%h", scaling_factor);
    $display("  init_x         = 0x%h", init_x);
    $display("  init_x float   = %f", (1.0 * init_x) / (1 << (WIDTH - 4))); // Convert to decimal for better understanding
    $display("  init_y         = 0x%h", init_y);
    $display("  init_angle     = 0x%h\n", init_angle);
    
    // Test Case 2:
    // scaling_factor representing 0.5 in U0.32.
    // 0.5 is represented as 2^(32-1)= 0x80000000.
    conv_result     = 32'hAAAAAAAA;  // arbitrary
    scaling_factor  = 32'h80000000;
    #1;
    $display("Test 2:");
    $display("  conv_result    = 0x%h", conv_result);
    $display("  scaling_factor = 0x%h", scaling_factor);
    $display("  init_x         = 0x%h  (expected approx 0x20000000 for 2.0)", init_x);
    $display("  init_x float   = %f", (1.0 * init_x) / (1 << (WIDTH - 4))); // Convert to decimal for better understanding
    $display("  init_y         = 0x%h", init_y);
    $display("  init_angle     = 0x%h\n", init_angle);
    
    // Test Case 3:
    // scaling_factor representing 0.25 in U0.32 (0.25 * 2^32 = 0x40000000).
    conv_result     = 32'h55555555;  // arbitrary
    scaling_factor  = 32'h40000000;
    #1;
    $display("Test 3:");
    $display("  conv_result    = 0x%h", conv_result);
    $display("  scaling_factor = 0x%h", scaling_factor);
    $display("  init_x         = 0x%h  (expected approx 0x40000000 for 4.0)", init_x);
    $display("  init_x float   = %f", (1.0 * init_x) / (1 << (WIDTH - 4))); // Convert to decimal for better understanding
    $display("  init_y         = 0x%h", init_y);
    $display("  init_angle     = 0x%h\n", init_angle);
    
    // Test Case 4:
    // scaling_factor representing 0.75 in U0.32 (0.75 * 2^32 ≈ 0xC0000000).
    conv_result     = 32'hDEADBEEF;  // arbitrary
    scaling_factor  = 32'hC0000000;
    #1;
    $display("Test 4:");
    $display("  conv_result    = 0x%h", conv_result);
    $display("  scaling_factor = 0x%h", scaling_factor);
    $display("  init_x         = 0x%h  (expected approx reciprocal of 0.75, i.e., ~1.3333)", init_x);
    $display("  init_x float   = %f", (1.0 * init_x) / (1 << (WIDTH - 4))); // Convert to decimal for better understanding
    $display("  init_y         = 0x%h", init_y);
    $display("  init_angle     = 0x%h\n", init_angle);
    
    // Test Case 5:
    // scaling_factor representing 0.125 in U0.32 (0.125 * 2^32 = 0x20000000).
    // Note: The reciprocal of 0.125 is 8.0, which is out of range for Q4.(WIDTH-4) with WIDTH=32 (range -8 to +7.999...)
    conv_result     = 32'h0F0F0F0F;  // arbitrary
    scaling_factor  = 32'h20000000;
    #1;
    $display("Test 5 (potential overflow case):");
    $display("  conv_result    = 0x%h", conv_result);
    $display("  scaling_factor = 0x%h", scaling_factor);
    $display("  init_x         = 0x%h", init_x);
    $display("  init_x float   = %f", (1.0 * init_x) / (1 << (WIDTH - 4))); // Convert to decimal for better understanding
    $display("  init_y         = 0x%h", init_y);
    $display("  init_angle     = 0x%h\n", init_angle);
    

    
    conv_result     = 32'h000091A4;  // arbitrary
    scaling_factor  = 32'h20000000;
    #1;
    $display("Test 5 (potential overflow case):");
    $display("  conv_result    = 0x%h", conv_result);
    $display("  scaling_factor = 0x%h", scaling_factor);
    $display("  init_x         = 0x%h", init_x);
    $display("  init_x float   = %f", (1.0 * init_x) / (1 << (WIDTH - 4))); // Convert to decimal for better understanding
    $display("  init_y         = 0x%h", init_y);
    $display("  init_angle     = 0x%h\n", init_angle);

    $display("tanh_initializer Testbench Finished.");
    $finish;
  end
  
endmodule
