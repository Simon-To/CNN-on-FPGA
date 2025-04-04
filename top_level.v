// top_level_cordic_constants.v
module top_level_cordic_constants (
    input  wire         clk,
    input  wire [3:0]   addr,        // 4-bit address; supports up to 16 entries (only DEPTH entries are used)
    output wire [15:0]  atanh_const, // output from atanh constants ROM
    output wire [15:0]  scale_const  // output from scaling factors ROM
);

    // initial begin
    //     reg [15:0] signed_rep = ; // Predefined constants for atanh
    // end

  // Instantiate the atanh constants ROM.
  atanh_constants_rom #(
    .DEPTH(10)
  ) atanh_rom_inst (
    .clk(clk),
    .addr(addr[$clog2(10)-1:0]), // Use only the bits needed for DEPTH entries
    .constant(atanh_const)
  );

  // Instantiate the scaling factors ROM.
  scaling_constants_rom #(
    .DEPTH(10)
  ) scale_rom_inst (
    .clk(clk),
    .addr(addr[$clog2(10)-1:0]),
    .constant(scale_const)
  );

endmodule
