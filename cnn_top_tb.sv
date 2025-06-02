`timescale 1ns / 1ps

module cnn_top_tb;

    // Parameters
    parameter WIDTH = 16; // Width of the input and output data
    parameter N = 5;      // Side length of original input matrix to Convolution Layer
    parameter K = 3;      // Side length of kernel of Convolution Layer
    parameter S = 1;      // Stride size (horizontal stride = vertical stride)

    // Clock and Reset
    reg clk;
    reg reset;

    // Output signals
    wire [WIDTH-1:0] top_output_result; // Output data from the CNN
    wire top_output_valid;              // Output valid signal
    wire top_output_end;                // Output end signal

    // Instantiate the cnn_top module
    cnn_top #(
        .WIDTH(WIDTH),
        .N(N),
        .K(K),
        .S(S)
    ) uut (
        .clk(clk),
        .reset(reset),
        .top_output_result(top_output_result),
        .top_output_valid(top_output_valid),
        .top_output_end(top_output_end)
    );

    // Clock generation

    initial clk = 0;
    always #5 clk = ~clk; // Toggle clock every 5 time units

    // Testbench stimulus
    initial begin
        reset = 1; // Assert reset initially
        #20 
        reset = 0; // Deassert reset after 10 time units

        // Add test cases here to drive inputs and check outputs
        wait (top_output_end && top_output_valid); // Wait for output to be valid and end signal
        // #100 $finish; // End simulation after some time
    end

endmodule