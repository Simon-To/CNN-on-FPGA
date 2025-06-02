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
    input wire signed [M-1:0] a, // Multiplier
    input wire signed [M-1:0] b, // Multiplicand
    input wire signed [M-1:0] c, // Accumulator
    // output [M-1:0] out 
    // CHANGE NOTE 1: Changing the output from a wire to a register
    // With this change, we're putting the responsibility of the storage
    // of the output on the user of the module
    // Implication: A register array is definition is required in the
    // outer module to store the output of the MAC unit
    // CHANGE NOTE 2: Changing the output from a register back to a wire
    // We are exporting the calculate value straight to the shift register
    // array element when the calculation is done.
    output wire signed [(M-1):0] out // 
    // output [(M-1):0] out // 
);

wire signed [(2 * M):0] full_result = $signed(a) * $signed(b) + $signed(c);

localparam signed [M-1:0] MAX_VAL =  (1 <<< (M-1)) - 1;
localparam signed [M-1:0] MIN_VAL = -(1 <<< (M-1));

assign out = ($signed(full_result) > MAX_VAL) ? MAX_VAL :
             ($signed(full_result) < MIN_VAL) ? MIN_VAL :
             $signed(full_result[M-1:0]);

// assign out = a * b + c;

// reg [M-1:0] temp_reg;
// REFER TO CHANGE NOTE 1
// REFER TO CHANGE NOTE 2
// always @(
//     // posedge clk or
//     posedge clk,
//     posedge rst
// ) begin
//     if (rst) begin
//         // If asynchronous reset is on
//         out <= 0; // Reset the register to 0
//         // out = 0; // Reset the register to 0
//         // REFER TO CHANGE NOTE 1
//     end 
//     else if (clk_en) begin
//         // If the async reset is off and the clock is enabled
//         // Normal MAC operation is performed
//         out <= a * b + c;
//         // out = a * b + c;
//         // REFER TO CHANGE NOTE 1
//     end
// end


// Note that temp_reg is directly assigned to out since temp_reg is 
// updated sequentially
// assign out = temp_reg;
// REFER TO CHANGE NOTE 1

// initial begin
//     $display("MAC unit simulation started");
// end
    
endmodule