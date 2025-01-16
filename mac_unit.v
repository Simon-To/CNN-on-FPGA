// MAC unit for integer (or fixed point in the future) arithmetic

// Infrastructure for future fixed point arithmetic
// `define FIXED_POINT 1
// Verified to be syntatically correct

module mac_unit #(
    parameter M = 16, // DEFAULT Width of integer bits
    parameter Q = 12 // DEFAULT Width of fractional bits
)(
    input clk, rst, clk_en,
    // MAC operation: out = a * b + c
    input [M-1:0] a, // Multiplier
    input [M-1:0] b, // Multiplicand
    input [M-1:0] c, // Accumulator
    output [M-1:0] out // 
);

reg [M-1:0] temp_reg;
always @(
    posedge clk,
    posedge rst
) begin
    if (rst) begin
        // If asynchronous reset is on
        temp_reg <= 0; // Reset the register to 0
    end 
    else if (clk_en) begin
        // If the async reset is off and the clock is enabled
        // Normal MAC operation is performed
        temp_reg <= a * b + c;
    end
end


// Note that temp_reg is directly assigned to out since temp_reg is 
// updated sequentially
assign out = temp_reg;

initial begin
    $display("MAC unit simulation started");
end
    
endmodule