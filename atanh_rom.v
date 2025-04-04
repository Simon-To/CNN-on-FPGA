// atanh_constants_rom.v
module atanh_constants_rom #(
    parameter DEPTH = 10  // number of constants (iterations)
)(
    input  wire         clk,    // clock signal
    input  wire [$clog2(DEPTH)-1:0] addr,  // address input; width computed from DEPTH
    output reg  [15:0]  constant // 16-bit constant output in Q1.15 format
);

  // Memory array to hold the constants.
  reg [15:0] mem [0:DEPTH-1];

  // Initialize the ROM contents from an external file.
  // The file "atanh_constants.mem" should be in the same directory as the source.
  initial begin
    $readmemh("atanh_constants.mem", mem);
  end

  // Provide constant value based on address.
  always @(posedge clk) begin
    $display("atanh constant in decimal = %d", mem[addr]);
    $display("atanh constant * 24 = %d", mem[addr] * 24);
    constant <= mem[addr];
  end

endmodule
