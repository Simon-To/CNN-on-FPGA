module tanh_initializer #(
    // MODULE VERIFIED (ALL CONCEPTS UNDERSTOOD)
    // parameters
    parameter WIDTH = 32 // Width of the input and output data
) (

    // Group 2: Input Signals
    input wire [(WIDTH - 1):0] conv_result, // Unsigned integer in binary
    input wire [(WIDTH - 1):0] scaling_factor, // U0.N unsigned fixed-point (already squared if double iteration)

    // Group 3: Output Signals
    output wire [(WIDTH - 1):0] init_x, // Q4.(N-4) signed fixed-point
    output wire [(WIDTH - 1):0] init_y, // Q4.(N-4) signed fixed-point
    // Previously: n-bit 2's complement integer in binary
    output wire [(WIDTH - 1):0] init_angle // Q4.(N-4) signed fixed-point
    // output wire [(WIDTH - 1):0] init_pow2 // n-bit 1/2 unsigned U0.N fixed-point
);
    // localparam for the bit width of the numerator.
    // localparam integer U0_Q4_CONVERSION_FACTOR = 2 * WIDTH - 4 + 1;
    // Compute the numerator constant (2^(2N-4)).
    // localparam [U0_Q4_CONVERSION_FACTOR-1:0] numerator = {1'b1, {(U0_Q4_CONVERSION_FACTOR-1){1'b0}}};
    // Turns out I don't have to square it because it has already been done by Python haha.
    // wire [((2 * WIDTH) - 1):0] scaling_factor_squared = scaling_factor * scaling_factor;
    // // scaling_factor_squared is in U0.(2N) format
    // wire [(WIDTH - 1):0] scaling_factor_sq_tr = scaling_factor_squared[((2 * WIDTH) - 1):WIDTH]; // Extract the lower WIDTH bits
    // wire [(WIDTH + (WIDTH - 4)):0] shifted_1 = {1'b1, {(WIDTH + (WIDTH - 4)){1'b0}}}; // 1 in U0.(N) format
    // wire [(WIDTH + (WIDTH - 4)):0] quotient = shifted_1 / scaling_factor_sq_tr; // Divide 1 by scaling_factor_squared in U0.(N) format
    // assign init_x = quotient[(WIDTH + (WIDTH - 4)) : (WIDTH - 1)] ? {1'b0, {(WIDTH - 1){1'b1}}} : quotient[(WIDTH - 1):0]; // Extract the lower WIDTH bits for init_x
    

    // wire [((2 * WIDTH) - 1):0] scaling_factor_squared = scaling_factor * scaling_factor;
    // scaling_factor_squared is in U0.(2N) format
    // wire [(WIDTH - 1):0] scaling_factor_sq_tr = scaling_factor_squared[((2 * WIDTH) - 1):WIDTH]; // Extract the lower WIDTH bits
    wire [(WIDTH + (WIDTH - 4)):0] shifted_1 = {1'b1, {(WIDTH + (WIDTH - 4)){1'b0}}}; // 1 in UN.(N-4) format
    wire [(WIDTH + (WIDTH - 4)):0] quotient = shifted_1 / scaling_factor; // Divide 1 by scaling_factor_squared in U0.(N) format
    // scaling factor = 1011 0000 0100 0011 1111 1110 1111 1100
    // init_x =         0001 0111 0011 1100 1101 0111 0010 1100
    assign init_x = quotient[(WIDTH + (WIDTH - 4)) : (WIDTH - 1)] ? {1'b0, {(WIDTH - 1){1'b1}}} : quotient[(WIDTH - 1):0]; // Extract the lower WIDTH bits for init_x


    
    // wire [U0_Q4_CONVERSION_FACTOR-1:0] full_result = numerator / scaling_factor_squared;

    
    // initial begin
    //     $monitor("U0_Q4_CONVERSION_FACTOR = %d, numerator = %h, scaling_factor = %h, full_result = %h", U0_Q4_CONVERSION_FACTOR, (1 << (2 * WIDTH - 4)), scaling_factor, full_result);
    // end

    // assign init_x = full_result[U0_Q4_CONVERSION_FACTOR-1 -: WIDTH];
    // Capping the result to fit in WIDTH bits
    // assign init_x = full_result[WIDTH - 1] ? {{1'b0}, {(WIDTH - 1){1'b1}}} : full_result[(WIDTH - 1):0];

    // initial begin
    //     #1;
    //     $monitor("conv_result = %h, shifted_1 = %b, scaling_factor = %b, quotient = %b", 
    //     conv_result, shifted_1, scaling_factor, quotient);
    // end


    assign init_y = {WIDTH{1'b0}}; // Initialize y to zero (Q4.(N-4) format)

    wire signed [(WIDTH - 1):0] Q4_conv_result = (conv_result[(WIDTH - 1) : 4]) ? {1'b0 , {(WIDTH - 1){1'b1}}} : {conv_result[3 : 0], {(WIDTH - 4){1'b0}}}; // Convert to Q4.(N-4) format
    wire signed [(WIDTH - 1):0] conv_result_signed;
    unsigned_to_signed #(
        .WIDTH(WIDTH)
    ) converter (
        .unsigned_val(Q4_conv_result), // Convert unsigned conv_result to signed
        .signed_val(conv_result_signed) // Output as signed value
    );
    assign init_angle = conv_result_signed; // Assign the signed conv_result directly to init_angle
    
    // assign init_pow2 = 1 << (WIDTH - 1); // Assign the full result as the initial power of 2 in U0.N format

    // initial begin
    //     #1;
    //     $monitor("tanh_initializer: conv_result = %h, scaling_factor = %h, init_x = %h, init_y = %h, init_angle = %h", 
    //              conv_result, scaling_factor, init_x, init_y, init_angle);

    // end
    

endmodule