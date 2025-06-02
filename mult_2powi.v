module mult_2powi #(
    parameter WIDTH = 32, // Bit-width for the input and output data
    parameter i     = 0   // iteration index, used for scaling factor
) (
    input wire signed [(WIDTH - 1):0] old, // Old x coordinate
    output wire signed [(WIDTH - 1):0] scaled // New x coordinate after multiplying by 2^(-i)
);
    // IMPORTANT NOTES ABOUT THIS MODULE:
    // 1. i MUST BE NEGATIVE OR ZERO, because if i > 0, it means we are 
    // multiplying by a power of 2 greater than 1, and we would need
    // extra bits to represent the result, which is not allowed in this module.
    // 2. This module multiplies the input 'old' by 2^(-i) in fixed-point format.
    // both old and new will be in signed fixed-point format Q4.(N-4)
    // As a result, we do NOT need to worry about overflow or underflow

    generate
        if (i < 0) begin
            assign scaled = old >>> (-i); // Right shift to divide by 2^|i|
        end else begin
            assign scaled = old;  // No shift
        end
    endgenerate
endmodule