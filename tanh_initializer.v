module tanh_initializer #(
    // MODULE VERIFIED
    // parameters
    parameter WIDTH = 32 // Width of the input and output data
) (

    // Group 2: Input Signals
    input wire [(WIDTH - 1):0] conv_result, // Unsigned integer in binary
    input wire [(WIDTH - 1):0] scaling_factor, // U0.N unsigned fixed-point

    // Group 3: Output Signals
    output wire [(WIDTH - 1):0] init_x, // Q4.(N-4) signed fixed-point
    output wire [(WIDTH - 1):0] init_y, // Q4.(N-4) signed fixed-point
    output wire [(WIDTH - 1):0] init_angle // n-bit unsigned integer in binary
);
    // localparam for the bit width of the numerator.
    localparam integer U0_Q4_CONVERSION_FACTOR = 2 * WIDTH - 4 + 1;
    // Compute the numerator constant (2^(2N-4)).
    localparam [U0_Q4_CONVERSION_FACTOR-1:0] numerator = {1'b1, {(U0_Q4_CONVERSION_FACTOR-1){1'b0}}};

    wire [U0_Q4_CONVERSION_FACTOR-1:0] full_result = numerator / scaling_factor;

    // initial begin
    //     $monitor("U0_Q4_CONVERSION_FACTOR = %d, numerator = %h, scaling_factor = %h, full_result = %h", U0_Q4_CONVERSION_FACTOR, (1 << (2 * WIDTH - 4)), scaling_factor, full_result);
    // end

    // assign init_x = full_result[U0_Q4_CONVERSION_FACTOR-1 -: WIDTH];
    assign init_x = full_result[(WIDTH - 1):0];

    assign init_y = {WIDTH{1'b0}}; // Initialize y to zero (Q4.(N-4) format)

    assign init_angle = conv_result; // Assign the input conv_result directly as the initial angle

endmodule