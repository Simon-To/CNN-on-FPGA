`timescale 1ns / 1ps


module convolver_tb;
    // Declare testbench signals
    // Inputs:
    reg clk;
    reg clk_en;
    reg reset;

    reg [143:0] kernel;
    reg [15:0] inputs;

    // Outputs:
    wire [15:0] conv_result;
	wire conv_end;
	wire result_valid;

    // Loop variable for iterating through the input matrix:
	integer i;

    // Clock Period
    parameter clk_period = 40;

    

    // Instantiate the design module
    convolution #(
        // .N(9'h004),
        // .K(9'h003),
        // .S(1),
        // .WIDTH(),
        // .Q(),
        // .padding(),
        9'h004,
        9'h003,
        1
    ) 
    design_under_test (
        .clk(clk),
        .clk_en(clk_en),
        .glb_rst(reset),
        .input_val(inputs),
        .kernel_1d(kernel),
        .conv_result(conv_result),
        .result_valid(result_valid),
        .conv_end(conv_end)
    );

    // Clock Signal Generation
    always #(clk_period / 2) clk = ~clk;

    // Initial block to define test stimulus
    initial begin
        // Open a waveform dump file for GTKWave (optional)
        $dumpfile("convolver_tb.vcd");
        $dumpvars(0, convolver_tb);

        // Initialize signals
        clk = 0;
        clk_en = 0;
        reset = 1;   // Apply reset
        kernel = 0;
        inputs = 0;

        // Remove reset and turn on clock enable after 
        // a clock period
        #(clk_period) 
        reset = 0;
        clk_en = 1;

        // Feed, at all clock cycles, the values of the kernel
        kernel = 144'h0008_0007_0006_0005_0004_0003_0002_0001_0000;

        for (i = 0; i < 16; i = i + 1) 
        begin
            
            inputs = i;
            #(clk_period);
        end

        // // Apply test values
        // #10 a = 4'b0011; b = 4'b0101; // Test case 1: a = 3, b = 5
        // #10 a = 4'b1010; b = 4'b0110; // Test case 2: a = 10, b = 6
        // #10 a = 4'b1111; b = 4'b1111; // Test case 3: a = 15, b = 15
        // #10 rst = 1;                 // Apply reset again
        // #10 rst = 0;

        // // End simulation after 50ns
        // #10 
        $finish;
    end

    // Use $monitor to print signal values whenever they change
    initial begin
        $monitor("Time: %0t | clk: %b | inputs: %b | conv_result: %0d | result_valid: %0d | conv_end: %0d", 
                 $time, clk, inputs, conv_result, result_valid, conv_end);
    end
endmodule