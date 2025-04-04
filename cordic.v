module cordic #(
    parameter WIDTH = 32 // Bit-width for coordinates and angles
) (

    input wire [(WIDTH - 1):0] old_x,
    input wire [(WIDTH - 1):0] old_y,
    input wire [(WIDTH - 1):0] old_angle, // n-bit unsigned integer in binary
    input wire [(WIDTH - 1):0] atanh, // arctanh constant for this iteration

    output wire [(WIDTH - 1):0] new_x,
    output wire [(WIDTH - 1):0] new_y,
    output wire [(WIDTH - 1):0] new_angle, // n-bit unsigned integer in binary
    output wire [(WIDTH - 1):0] atanh_out // output the atanh constant
);

    

    
endmodule