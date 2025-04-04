// scaling_constants_rom.v
module scaling_constants_rom #(
    parameter DEPTH = 10  // number of constants (iterations)
)(
    input  wire         clk,    // clock signal
    input  wire [$clog2(DEPTH)-1:0] addr,  // address input
    output reg  [15:0]  constant // 16-bit constant output in Q2.14 format
);

  // Memory array to hold scaling factors.
  reg [15:0] mem [0:DEPTH-1];

  // Initialize the ROM contents from an external file.
  initial begin
    $readmemh("scaling_constants.mem", mem);
  end

  // Output the scaling factor at the given address.
  always @(posedge clk) begin
    
    constant <= mem[addr];
  end

endmodule
