module cordic #(
    // MODULE VERIFIED (ALL CONCEPTS UNDERSTOOD)
    parameter WIDTH = 32, // Bit-width for coordinates and angles
    parameter i     = 0 // iteration index, used for atanh constant selection
) (

    input wire signed [(WIDTH - 1):0] old_x,    // Format: Q4.(WIDTH-4) signed fixed-point binary
    input wire signed [(WIDTH - 1):0] old_y,    // Format: Q4.(WIDTH-4) signed fixed-point binary
    input wire signed [(WIDTH - 1):0] old_angle, // Format: Q4.(WIDTH-4) signed fixed-point binary
    input wire [(WIDTH - 1):0] atanh,           // Format: U0.WIDTH unsigned fixed-point binary
    // input wire [(WIDTH - 1):0] this_pow2, // 1/2^(-i) in U0.N fixed-point format

    output wire signed [(WIDTH - 1):0] new_x,   // Format: Q4.(WIDTH-4) signed fixed-point binary
    output wire signed [(WIDTH - 1):0] new_y,   // Format: Q4.(WIDTH-4) signed fixed-point binary
    // Previous Format: signed integer binary
    output wire signed [(WIDTH - 1):0] new_angle  // Format: Q4.(WIDTH-4) signed fixed-point binary
    
    // output wire signed [(2*WIDTH - 1):0] debug // For debugging purposes only
    // output wire [(WIDTH - 1):0] atanh_out // output the atanh constant
    // output wire [(WIDTH - 1):0] next ._pow2 // 1/2^(-(i+1)) in U0.N fixed-point format
);
    // Local Parameters that specify the max and min boundaries for 
    // localparam signed [(WIDTH-1):0] MAX_VAL =  (1 <<< (WIDTH-1)) - 1;
    // localparam signed [(WIDTH-1):0] MIN_VAL = -(1 <<< (WIDTH-1));

    // initial begin
    //     $monitor("CORDIC Iteration %0d: old_x = %b, old_y = %b, old_angle = %b, atanh = %b", 
    //              i, old_x, old_y, old_angle, atanh);
    // end
            
    
    // Step 1: Determine rotation direction of this iteration based on old_angle
    // double di = (old_angle < 0) ? -1 : 1;
    // wire signed [1:0] di = ($signed(old_angle) < {(WIDTH){1'b0}}) ? -1 : 1; 
    wire signed [1:0] di = ($signed(old_angle) < 0) ? -1 : 1; 
    // initial begin
    //     $monitor("Iteration %0d: di = %d", i, di);
    // end



    // Step 2: Calculate new x:
    // Step 2.1: Calculate the negated old_y:
    wire signed [(WIDTH - 1):0] negated_old_y;
    binary_negater #(
        .WIDTH(WIDTH)
    ) flip_y (
        .in_data(old_y), // old_y is the input to be inverted
        .out_data(negated_old_y) // old_y is inverted to di_old_y
    );
    // Step 2.2: Calculate di_old_y = di * y:
    // di_old_y format: Q4.(WIDTH-4) signed fixed-point binary
    wire signed [(WIDTH - 1):0] di_old_y = ($signed(di) == 2'b01) ? old_y : negated_old_y; // Handle direction
    
    // initial begin
    //     $monitor("Iteration %0d: old_y = %b, negated_old_y = %b, di_old_y = %b", 
    //              i, old_y, negated_old_y, di_old_y);
    // end

    // Step 2.3: Calculate di_old_y_pow2 = di * y * pow(2, -i)
    // di_old_y_pow2 format: Q4.(WIDTH-4) signed fixed-point binary
    wire signed [(WIDTH - 1):0] di_old_y_pow2;
    mult_2powi #(
        .WIDTH(WIDTH),
        .i(-i) // i is the iteration index
    ) y_2powi (
        .old(di_old_y), // old_y scaled by 2^(-i)
        .scaled(di_old_y_pow2) // new scaled value
    );

    // initial begin
    //     $monitor("Iteration %0d: old_y = %b, di_old_y = %b, di_old_y_pow2 = %b", 
    //              i, old_y, di_old_y, di_old_y_pow2);
    // end

    // Step 2.4: Calculate new x coordinate:
    // new_x = x + di * y * pow(2, -i);
    // new_x format: Q4.(WIDTH-4) signed fixed-point binary
    wire signed [WIDTH:0] new_x_temp = $signed(old_x) + $signed(di_old_y_pow2); // Calculate new x coordinate

    assign new_x = (new_x_temp >  $signed({1'b0, {(WIDTH-1){1'b1}}})) ? $signed({1'b0, {(WIDTH-1){1'b1}}}) :  // +MAX
                 (new_x_temp <  $signed({1'b1, {(WIDTH-1){1'b0}}})) ? $signed({1'b1, {(WIDTH-1){1'b0}}}) :  // -MIN
                 new_x_temp[(WIDTH-1):0];

    // assign new_x = new_x_temp

    // initial begin
    //     $monitor("Iteration %0d: old_x = %b, old_y = %b, di_old_y_pow2 = %b, new_x = %b", 
    //              i, old_x, old_y, di_old_y_pow2, new_x);
    // end

    // Step 3: Calculate new y:
    wire signed [(WIDTH - 1):0] negated_old_x;
    binary_negater #(
        .WIDTH(WIDTH)
    ) flip_x (
        .in_data(old_x), // old_x is the input to be inverted
        .out_data(negated_old_x) // old_x is inverted to di_old_x
    );
    wire signed [(WIDTH - 1):0] di_old_x = ($signed(di) == 2'b01) ? old_x : negated_old_x; // Handle direction

    

    wire signed [(WIDTH - 1):0] di_old_x_pow2;
    mult_2powi #(
        .WIDTH(WIDTH),
        .i(-i) // i is the iteration index
    ) x_2powi (
        .old(di_old_x), // old_x scaled by 2^(-i)
        .scaled(di_old_x_pow2) // new scaled value
    );

    wire signed [WIDTH:0] new_y_temp = $signed(old_y) + $signed(di_old_x_pow2); // Calculate new y coordinate

    assign new_y = (new_y_temp >  $signed({1'b0, {(WIDTH-1){1'b1}}})) ? $signed({1'b0, {(WIDTH-1){1'b1}}}) :  // +MAX
                 (new_y_temp <  $signed({1'b1, {(WIDTH-1){1'b0}}})) ? $signed({1'b1, {(WIDTH-1){1'b0}}}) :  // -MIN
                 new_y_temp[(WIDTH-1):0];
    // assign new_y = old_y + di_old_x_pow2; // Calculate new y coordinate


    // initial begin
    //     $monitor("Iteration %0d: old_x = %b, old_y = %b, di_old_x_pow2 = %b, new_y = %b", 
    //              i, old_x, old_y, di_old_x_pow2, new_y);
    // end
    
    
    // Step 4: Calculate new angle:
    // 1. Get signed atanh value and handle direction;
    // 1.1 Converting atanh from U0.WIDTH to Q1.WIDTH by adding a sign bit to the left
    // wire signed [(WIDTH - 1):0] atanh_signed = {1'b0, atanh[(WIDTH - 1):1]}; // Convert U0.WIDTH to Q1.WIDTH signed fixed-point binary
    
    wire signed [WIDTH : 0] atanh_signed = {1'b0, atanh};

    // unsigned_to_signed #(
    //     .WIDTH(WIDTH)
    // ) converter (
    //     .unsigned_val(atanh), // Convert unsigned atanh to signed
    //     .signed_val(atanh_signed) // Output as signed value
    // );

    wire signed [WIDTH : 0] negated_atanh_signed;
    binary_negater #(
        .WIDTH(WIDTH + 1) // Add 1 to the width to accommodate the sign bit
    ) flip_atanh (
        .in_data(atanh_signed), // atanh_signed is the input to be inverted
        .out_data(negated_atanh_signed) // atanh_signed is inverted to negated_atanh_signed
    );

    // wire signed [WIDTH:0] di_ext = {{(WIDTH-1){di[1]}}, di}; // Sign-extend di to WIDTH+1
    wire signed [WIDTH:0] di_atanh = ($signed(di) > 0) ? atanh_signed : negated_atanh_signed;


    // wire signed [WIDTH:0] di_atanh = ($signed(di) > 0) ? atanh_signed : negated_atanh_signed; // Handle direction

    // 2. Calculate new angle in full precision (Q4.)
    wire signed [((WIDTH - 1) + 4):0] old_angle_q0n = ($signed(old_angle) <<< 4);
    

    // Align atanh to same width
    wire signed [((WIDTH - 1) + 4):0] atanh_ext = ({{(4 - 1){di_atanh[WIDTH]}}, di_atanh}); // Extend atanh to match the width of old_angle_q0n

    // initial begin
    //     $monitor("old_angle_q0n = %b, atanh_ext = %b", old_angle_q0n, di_atanh);
    // end
    // 0000 0000 0000 1100
    // 0000 0000 0000 0000

    // Perform subtraction in full-precision space
    wire signed [((WIDTH - 1) + 4):0] result_q0n = $signed(old_angle_q0n) - $signed(atanh_ext);
    // wire signed [(2*WIDTH)-1:0] result_q0n = (old_angle_q0n) - (atanh_ext);
    // wire signed [(2*WIDTH)-1:0] stupid_ass = $signed(32'b00000000000000010000000000000000) - $signed(32'b00000000000000001000110010011111);
    // Truncate (or round, or saturate) back to N-bit result 
    // assign new_angle = result_q0n[((2*WIDTH)-1) -: WIDTH];  // Keep the top N bits
    // assign new_angle = old_angle_q0n[((2*WIDTH)-1):WIDTH]; // Keep the top N bits
    // assign new_angle = di_atanh[(WIDTH - 1) : 0]; // Keep the top N bits
    // assign new_angle = (negated_atanh_signed[(WIDTH - 1) : 0]);
    // assign new_angle =  ($signed(di) > 0)? 1 : 0; // Keep the top N bits
    assign new_angle = result_q0n[((WIDTH - 1) + 4):4];
    // assign new_angle = atanh_ext[((WIDTH - 1) + 4):4];
    // assign util = 
    // assign new_angle = di;

    // assign new_angle = result_q0n[((2*WIDTH)-1) : WIDTH];
    // assign new_angle = atanh_ext[WIDTH - 1:0]; // Keep the top N bits
    
    // atanh_signed = 01000110010100100
    // new_angle = 1000 1100 1001 1111

    // initial begin
    //     #2;
    //     $monitor("Time: %0t, Iteration %0d: old_angle = %b, atanh_signed = %b, negated_atanh_signed = %b, di_atanh = %b, old_angle_q0n = %b, atanh_ext = %b, result_q0n = %b, new_angle = %b", 
    //              $time, i, old_angle, atanh_signed, negated_atanh_signed, di_atanh, old_angle_q0n, atanh_ext, result_q0n, new_angle);
    // end
    



    // initial begin
    //     $monitor("Iteration %0d: old_angle = %h, atanh_signed = %b, negated_atanh_signed = %b, di_atanh = %b, old_angle_q0n = %b, atanh_ext = %b, result_q0n = %b, new_angle = %b", 
    //     i, old_angle, atanh_signed,negated_atanh_signed, di_atanh, old_angle_q0n, atanh_ext, result_q0n, new_angle);
    // end






    
    // wire signed [(WIDTH + 1):0] new_angle_temp = $signed(old_angle) - $signed(di) * $unsigned(atanh);
    // 2. Saturate new angle to the max/min values
    // assign new_angle =  ($signed(new_angle_temp) > MAX_VAL) ? MAX_VAL :
    //                     ($signed(new_angle_temp) < MIN_VAL) ? MIN_VAL :
    //                     $signed(new_angle_temp[(WIDTH-1):0]); 
    

    // Step 5: Output the atanh constant for the next iteration
    // assign atanh_out = atanh; // Pass through the atanh constant for this iteration

// localparam signed [M-1:0] MAX_VAL =  (1 <<< (M-1)) - 1;
// localparam signed [M-1:0] MIN_VAL = -(1 <<< (M-1));

// assign out = (full_result > MAX_VAL) ? MAX_VAL :
//              (full_result < MIN_VAL) ? MIN_VAL :
//              $signed(full_result[M-1:0]);

// atanh_signed =         01000110010100100, 
// negated_atanh_signed = 10111001101011100, 
// di_atanh = 01000110010100100, 
//             xxxxxxxxxxxxxxxx
// new_angle = 1111111111111111
//      1111111111111111

endmodule