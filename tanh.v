module tanh #(
    // parameters
    parameter WIDTH = 32 // Width of the input and output data
) (
    // Group 1: Control Signals
    input clk,              // Clock signal
    input clk_en,           // Clock enables
    // Async, Active High Reset
    input glb_rst,          // Global reset signal

    // Group 2: Input Signals
    input wire [(WIDTH - 1):0] conv_result,
    input wire result_valid_in,
    input wire conv_end_in,

    // Group 3: Output Signals
    output wire [(WIDTH - 1):0] tanh_result,
    output wire result_valid_out,
    output wire conv_end_out
);
    // Part 1: Initialize compile-time data
    // Step 1: Combinationally fetch the Scaling Factor 
    // from scaling_constants.mem

    // Please note the only reason scaling_factor_mem is 
    // declared as a 2D array is because $readmemh requires it to be
    // a "memory" type, which is a 2D array in Verilog.
    reg [(WIDTH - 1):0] scaling_factor_mem [0:1];
    // Assign the first entry as the scaling factor
    // ** Format of scaling_factor is U0.N (unsigned fixed-point) **
    wire [(WIDTH - 1):0] scaling_factor = scaling_factor_mem[0]; 

    real scale;
    real decimal_scaling_factor;
    integer j;

    initial begin
        scale = 1.0;
        for (j = 0; j < WIDTH; j = j + 1) begin
            scale = scale * 2.0;
        end

        $readmemh("scaling_constants.mem", scaling_factor_mem);
        $display("Scaling factor initialized: %h", scaling_factor_mem[0]);

        decimal_scaling_factor = scaling_factor_mem[0] / scale;

        $display("Decimal Scaling Factor: %f", decimal_scaling_factor);

        // #5;

        $monitor("Scaling factor in binary: %h", scaling_factor);
        
    end

    
    // Step 2: Sequentially fetch the arctanh constants of each iteration
    // from atanh_constants.mem

    reg [(WIDTH - 1):0] atanh_mem [0:(WIDTH - 1)];
    
    initial begin
        $readmemh("atanh_constants.mem", atanh_mem);
        $display("atanh constants initialized.");
    end

    // Part 2: Construct pipeline stages for CORDIC algorithm
    reg [(4 * WIDTH - 1):0] stage_registers [0:WIDTH];
    // Explanation of stage_registers:
    // There are WIDTH + 1 stages in total, where:
    // stage_registers[0] will hold the initial values 
    // (init_x, init_y, init_angle, atanh_mem[0])
    // stage_registers[i] holds the intermediate results of the CORDIC stages.
    // Notice that stage_registers[WIDTH]'s least significant WIDTH-bits
    // is not used because the last stage does not require any calculation
    // that needs atanh value.

    
    // Step 3: Instantiating Initial Stage:
    // Initialize the input x and y values for the tanh function

    wire [(WIDTH - 1):0] init_x;
    wire [(WIDTH - 1):0] init_y;
    wire [(WIDTH - 1):0] init_angle;

    tanh_initializer initializer #(WIDTH) (
        .conv_result(conv_result), // Input from the converter
        .scaling_factor(scaling_factor), // Scaling factor fetched from ROM
        .init_x(init_x), // Q4.14 signed fixed-point
        .init_y(init_y), // Q4.14 signed fixed-point
        .init_angle(init_angle) // n-bit unsigned integer in binary
    );

    // Step 4: Instantiating CORDIC Stages:
    
    
    


    


    // Combinational access
    // assign data_out = scaling_factor;

    
endmodule