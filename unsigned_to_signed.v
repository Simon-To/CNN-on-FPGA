module unsigned_to_signed #(
    parameter WIDTH = 32 // Bit-width for the input and output data
) (
    input wire unsigned [(WIDTH - 1):0] unsigned_val, // Unsigned integer in binary
    output wire signed [(WIDTH - 1):0] signed_val // Signed integer in binary
);
    
    wire signed [WIDTH-1:0] MAX_SIGNED = {1'b0, {(WIDTH-1){1'b1}}}; // +2^(WIDTH-1)-1

    // Check if the input is greater than the maximum representable signed value
    // If it is, cap it to the maximum signed value
    // If not, assign it directly
    assign signed_val = (unsigned_val > MAX_SIGNED) ? MAX_SIGNED : unsigned_val;
    
endmodule