`define VALID_BIT   ((3 * WIDTH - 1) + 2)
`define END_BIT     ((3 * WIDTH - 1) + 1)
`define X_FIELD     ((3 * WIDTH - 1):(2 * WIDTH))
`define Y_FIELD     ((2 * WIDTH - 1):(WIDTH))
`define ANGLE_FIELD ((WIDTH - 1):0)

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
    input wire [(WIDTH - 1):0] conv_result, // Unsigned integer input from Convolution Layer
    input wire result_valid_in,             // 1-bit valid signal from Convolution Layer
    input wire conv_end_in,                 // 1-bit end signal from Convolution Layer

    // Group 3: Output Signals
    output wire [(WIDTH - 1):0] tanh_result,// Output of the tanh function in Q1.(WIDTH - 1) signed binary format
    output wire result_valid_out,           // 1-bit valid signal to next layer
    output wire conv_end_out                // 1-bit end signal to next layer
);
    // Part 1: Initialize compile-time data
    // Step 1: Combinationally fetch the Scaling Factor 
    // from scaling_constants.mem

    // Please note the only reason scaling_factor_mem is 
    // declared as a 2D array is because $readmemh requires it to be
    // a "memory" type, which is a 2D array in Verilog.
    reg [(WIDTH - 1):0] scaling_factor_mem [0:1];
    // Assign the first entry as the scaling factor
    // *FINAL* Format of scaling_factor is U0.N (unsigned fixed-point) **
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
        $display("Scaling factor initialized: %b", scaling_factor_mem[0]);

        decimal_scaling_factor = scaling_factor_mem[0] / scale;

        $display("Decimal Scaling Factor: %f", decimal_scaling_factor);

        // #5;

        $monitor("Scaling factor in binary: %h", scaling_factor);
        
    end

    
    // Step 2: Sequentially fetch the arctanh constants of each iteration
    // from atanh_constants.mem

    // ** Format of atanh is U0.N (unsigned fixed-point) **
    reg [(WIDTH - 1):0] atanh_mem [0:(WIDTH - 1)];
    
    integer i;
    initial begin
        $readmemh("atanh_constants.mem", atanh_mem);
        $display("atanh constants initialized.");
        for (i = 0; i < WIDTH; i = i + 1) begin
            $display("atanh[%0d] = %b", i, atanh_mem[i]);
        end
    end

    // Part 2: Construct pipeline stages for CORDIC algorithm
    reg [((3 * WIDTH - 1) + 2):0] stage_registers [0:WIDTH];
    // Explanation of stage_registers:
    // There are WIDTH + 1 stages in total, where:
    // stage_registers[0] will hold the initial values 
    // (init_x, init_y, init_angle)
    // stage_registers[i] holds the intermediate results of the CORDIC stages.
    // Notice that stage_registers[WIDTH]'s least significant WIDTH-bits
    // is not used because the last stage does not require any calculation
    // that needs atanh value.

    
    // Step 3: Instantiating Initial Stage:
    // Step 3.1: Initialize the input x and y values for the tanh function

    wire [(WIDTH - 1):0] init_x;
    wire [(WIDTH - 1):0] init_y;
    wire [(WIDTH - 1):0] init_angle;

    tanh_initializer #(.WIDTH(WIDTH)) initializer (
        .conv_result(conv_result), // Input from the converter
        .scaling_factor(scaling_factor), // Scaling factor fetched from ROM
        .init_x(init_x), // Q4.14 signed fixed-point
        .init_y(init_y), // Q4.14 signed fixed-point
        .init_angle(init_angle) // n-bit 2's complement signed integer in binary
    );

    // initial begin
    //     $monitor("time: %0t, conv_result = %b, scaling_factor = %b, init_x = %b, init_y = %b, init_angle = %b", 
    //              $time, conv_result, scaling_factor, init_x, init_y, init_angle);
    // end

    // Step 3.2: Assign the initial values to the first stage register
    always @(posedge clk) begin
        if (glb_rst) begin
            stage_registers[0] <= 0; // Reset to initial values
        end else if (clk_en) begin
            stage_registers[0] <= {
                result_valid_in, 
                conv_end_in, 
                init_x, 
                init_y, 
                init_angle
            }; // Load initial values on clock enable

            if (stage_registers[0][((3 * WIDTH - 1) + 2)] && stage_registers[0][((3 * WIDTH - 1) + 1)]) begin
                $display("At time %t: Stage 0: valid=1, end=1, x=%b, y=%b, angle=%h", 
                        $time, 
                        stage_registers[0][(3 * WIDTH - 1):(2 * WIDTH)], 
                        stage_registers[0][(2 * WIDTH - 1):(WIDTH)], 
                        stage_registers[0][(WIDTH - 1):0]);
            end
        end
    end



    // Step 4: Instantiating CORDIC Stages:
    // Step 4.1: Instantiate output wires for CORDIC combinational logic
    wire [(WIDTH - 1):0] new_x [0:(WIDTH - 1)];   // Q4.(WIDTH-4) signed fixed-point binary
    wire [(WIDTH - 1):0] new_y [0:(WIDTH - 1)];   // Q4.(WIDTH-4) signed fixed-point binary
    wire [(WIDTH - 1):0] new_angle [0:(WIDTH - 1)]; // n-bit 2's complement signed integer in binary

    wire [(WIDTH - 1):0] intermediate_x [0:(WIDTH - 1)];   // Q4.(WIDTH-4) signed fixed-point binary
    wire [(WIDTH - 1):0] intermediate_y [0:(WIDTH - 1)];   // Q4.(WIDTH-4) signed fixed-point binary
    wire [(WIDTH - 1):0] intermediate_angle [0:(WIDTH - 1)]; // n-bit 2's complement signed integer in binary

    // wire [(2*WIDTH - 1):0] debug_out_1 [0:(WIDTH - 1)]; // Debug output for the first stage
    // wire [(2*WIDTH - 1):0] debug_out_2 [0:(WIDTH - 1)]; // Debug output for the second stage

    // Step 4.2: Establish CORDIC pipeline stages
    generate
        genvar k;
        // genvar l;


        for (k = 1; k <= WIDTH; k = k + 1) begin : cordic_stages
            // Step 4.2.1: Assign the output of the previous stage to the current stage
            always @(posedge clk) begin
                if (glb_rst) begin
                    stage_registers[k] <= 0; // Reset to initial values
                end
                else if (clk_en) begin
                    stage_registers[k] <= {
                        // For valid and end signals, we just simply propagate them through the pipeline:
                        stage_registers[k - 1][((3 * WIDTH - 1) + 2):(3 * WIDTH)], 
                        new_x[k - 1], // x output from previous stage
                        new_y[k - 1], // y output from previous stage
                        new_angle[k - 1] // angle output from previous stage
                    };
                end
            end
            
            // Step 4.2.2: Instantiate the CORDIC stage module
            cordic #(
                .WIDTH(WIDTH),
                .i(k) // i is the iteration index
            ) cordic_iteration_1 (
                // Input signals from the previous stage
                .old_x(stage_registers[k - 1][(3 * WIDTH - 1):(2 * WIDTH)]), // x input from previous stage
                .old_y(stage_registers[k - 1][(2 * WIDTH - 1):(WIDTH)]), // y input from previous stage
                .old_angle(stage_registers[k - 1][(WIDTH - 1):0]), // angle input from previous stage
                .atanh(atanh_mem[k - 1]), // atanh constant for this iteration
                
                // Output signals to the next stage
                .new_x(intermediate_x[k - 1]), // x output for this stage
                .new_y(intermediate_y[k - 1]), // y output for this stage
                .new_angle(intermediate_angle[k - 1]) // angle output for this stage
                // .debug(debug_out_1) // Debug output for the first stage
            );

            cordic #(
                .WIDTH(WIDTH),
                .i(k) // i is the iteration index
            ) cordic_iteration_2 (
                // Input signals from the previous stage
                .old_x(intermediate_x[k - 1]), // x input from previous stage
                .old_y(intermediate_y[k - 1]), // y input from previous stage
                .old_angle(intermediate_angle[k - 1]), // angle input from previous stage
                .atanh(atanh_mem[k - 1]), // atanh constant for this iteration
                
                // Output signals to the next stage
                .new_x(new_x[k - 1]), // x output for this stage
                .new_y(new_y[k - 1]), // y output for this stage
                .new_angle(new_angle[k - 1]) // angle output for this stage
            );

            always @(posedge clk) begin
                if (clk_en) begin
                    // if (stage_registers[k][((3 * WIDTH - 1) + 2)] && stage_registers[k][((3 * WIDTH - 1) + 1)]) begin
                    //     $display("At time %t: Stage %0d: valid=1, end=1, x=%b, y=%b, angle=%b, atanh=%b", 
                    //             $time, 
                    //             k, 
                    //             stage_registers[k][(3 * WIDTH - 1):(2 * WIDTH)], 
                    //             stage_registers[k][(2 * WIDTH - 1):(WIDTH)], 
                    //             stage_registers[k][(WIDTH - 1):0],
                    //             atanh_mem[k - 1]
                    //             );
                    // end

                    // if (stage_registers[k-1][((3 * WIDTH - 1) + 2)] && stage_registers[k-1][((3 * WIDTH - 1) + 1)]) begin
                    //     // $display("At time %t: Stage %0d: valid=1, end=1, x=%b, y=%b, angle=%b, atanh=%b", 
                    //     $display("At time %t: Stage %0d: intermediate_x= %b, intermediate_y= %b, intermediate_angle= %b, new_x= %b, new_y= %b, new_angle= %b, atanh= %b",
                    //             $time, 
                    //             // (k - 1), 
                    //             // stage_registers[k - 1][(3 * WIDTH - 1):(2 * WIDTH)], 
                    //             // stage_registers[k - 1][(2 * WIDTH - 1):(WIDTH)], 
                    //             // stage_registers[k - 1][(WIDTH - 1):0],
                    //             // atanh_mem[k - 1],
                    //             (k), 
                    //             intermediate_x[k - 1], 
                    //             intermediate_y[k - 1],
                    //             intermediate_angle[k - 1],
                    //             new_x[k - 1],
                    //             new_y[k - 1],
                    //             new_angle[k - 1],
                    //             atanh_mem[k - 1],
                                

                    //             );
                    // end
                end
            end


            // always @(posedge clk) begin
            //     if (clk_en) begin
            //         $display("Stage %0d: valid=%b, end=%b, x=%h, y=%h, angle=%h", 
            //                 k, 
            //                 stage_registers[k][((3 * WIDTH - 1) + 2)], 
            //                 stage_registers[k][((3 * WIDTH - 1) + 1)], 
            //                 stage_registers[k][(3 * WIDTH - 1):(2 * WIDTH)], 
            //                 stage_registers[k][(2 * WIDTH - 1):(WIDTH)], 
            //                 stage_registers[k][(WIDTH - 1):0]);
            //     end
            // end

        end

        
    endgenerate


    
    // Step 5: Calculate the final output signals
    // Step 5.1: Shift the y output left by (WIDTH-1) bits to form 
    // a shifted y, which would be the numerator
    wire signed [(2 * WIDTH - 2):0] shifted_y = ((stage_registers[WIDTH][(2 * WIDTH - 1):(WIDTH)]) <<< (WIDTH - 1)); // Shift y left by (WIDTH-1) bits

    // Step 5.2: Calculate the final tanh result
    assign tanh_result = $signed(shifted_y) / $signed(stage_registers[WIDTH][(3 * WIDTH - 1):(2 * WIDTH)]); // Divide shifted y by x to get tanh result
    
    // Step 5.3: Assign the valid and end signals for the output
    assign result_valid_out = stage_registers[WIDTH][((3 * WIDTH - 1) + 2)];
    assign conv_end_out = stage_registers[WIDTH][((3 * WIDTH - 1) + 1)];

    // initial begin
    //     $monitor("shifted_y = %b, new_y = %b, new_x = %b, tanh_result = %b", 
    //              shifted_y, new_y[WIDTH - 1], new_x[WIDTH - 1], tanh_result);
    //     // $monitor("result_valid_out = %b, conv_end_out = %b",
    //     //          result_valid_out, conv_end_out);
    // end

    // 000 0000 0000 0000 0000 0000 0000 0000




    


    

    
endmodule