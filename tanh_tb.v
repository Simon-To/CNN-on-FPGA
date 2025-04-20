`timescale 1ns/1ps

module tanh_tb;

    parameter WIDTH = 32;

    // DUT Inputs
    reg clk;
    reg clk_en;
    reg glb_rst;
    reg [WIDTH-1:0] conv_result;
    reg result_valid_in;
    reg conv_end_in;

    // DUT Outputs
    wire [WIDTH-1:0] tanh_result;
    wire result_valid_out;
    wire conv_end_out;

    // Instantiate the DUT
    tanh #(
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),
        .clk_en(clk_en),
        .glb_rst(glb_rst),
        .conv_result(conv_result),
        .result_valid_in(result_valid_in),
        .conv_end_in(conv_end_in),
        .tanh_result(tanh_result),
        .result_valid_out(result_valid_out),
        .conv_end_out(conv_end_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz clock

    // Fixed test vectors in Q1.31 format (32-bit signed fixed-point)
    // Format: {input, expected_output}
    // You can generate these values using Python or MATLAB beforehand
    reg [WIDTH-1:0] test_inputs[0:6];
    reg [WIDTH-1:0] expected_outputs[0:6];
    integer i;

    // Function to compute absolute error in simulation (difference in fixed-point)
    function [WIDTH-1:0] abs_diff;
        input [WIDTH-1:0] a;
        input [WIDTH-1:0] b;
        begin
            if ($signed(a) > $signed(b))
                abs_diff = a - b;
            else
                abs_diff = b - a;
        end
    endfunction

    initial begin
        // $monitor("At time %t: tanh_result = 0x%h, result_valid_out = %b, conv_end_out = %b",
        //          $time, tanh_result, result_valid_out, conv_end_out);
        // $monitor("$time result_valid_in = %b, conv_end_in = %b, conv_result = 0x%h, tanh_result = 0x%b, result_valid_out = %b, conv_end_out = %b",
        //          result_valid_in, conv_end_in, conv_result, tanh_result, result_valid_out, conv_end_out);
        // $monitor("At time %t: result_valid_in = %b, conv_end_in = %b, conv_result = 0x%h, tanh_result = 0x%h, result_valid_out = %b, conv_end_out = %b",
        //          $time, result_valid_in, conv_end_in, conv_result, tanh_result, result_valid_out, conv_end_out);
        // #1;
        // $monitor("At time %t: result_valid_in = %b, conv_end_in = %b, conv_result = 0x%h",
        //          $time, result_valid_in, conv_end_in, conv_result);
    end

    initial begin
        // Initialize signals
        clk_en = 1;
        glb_rst = 1;
        conv_result = 0;
        result_valid_in = 0;
        conv_end_in = 0;

        // Wait and release reset
        #20;
        glb_rst = 0;

        // Precomputed Q1.31 test vectors
        // tanh(0.0) = 0
        // tanh(1.0) ≈ 0.7615 → 0x6174EC52
        // tanh(-1.0) ≈ -0.7615 → 0x9E8B13AE
        // tanh(5.0) ≈ 0.9999 → 0x7FFFFFFF
        // tanh(-5.0) ≈ -0.9999 → 0x80000001
        // tanh(10.0) ≈ 1.0 → 0x7FFFFFFF
        // tanh(-10.0) ≈ -1.0 → 0x80000001

        test_inputs[0]      = 32'h00000000; // 0.0
        expected_outputs[0] = 32'h00000000; // 0.0

        test_inputs[1]      = 32'h40000000; // +1.0 in Q1.31
        expected_outputs[1] = 32'h6174EC52; // tanh(1.0)

        test_inputs[2]      = 32'hC0000000; // -1.0 in Q1.31
        expected_outputs[2] = 32'h9E8B13AE; // tanh(-1.0)

        test_inputs[3]      = 32'hA0000000; // -5.0 (approx)
        expected_outputs[3] = 32'h80000001; // tanh(-5.0)

        test_inputs[4]      = 32'h20000000; // +5.0 (approx)
        expected_outputs[4] = 32'h7FFFFFFF; // tanh(5.0)

        test_inputs[5]      = 32'h50000000; // +10.0 (approx)
        expected_outputs[5] = 32'h7FFFFFFF; // tanh(10.0)

        test_inputs[6]      = 32'hB0000000; // -10.0 (approx)
        expected_outputs[6] = 32'h80000001; // tanh(-10.0)

        $display("==== Starting tanh testbench ====");

        // 0000 0001 0110 0001 1101 1101 0110 1011
        // @(posedge clk);
        // #1;
        // conv_result = 32'h00000000;
        // result_valid_in = 0;
        // conv_end_in = 0;

        @(posedge clk);
        #1;
        conv_result = 32'h00000001;
        result_valid_in = 1;
        conv_end_in = 1;

        @(posedge clk);
        #1;
        conv_result = 32'h00000002;
        result_valid_in = 1;
        conv_end_in = 1;

        @(posedge clk);
        #1;
        result_valid_in = 0;
        conv_end_in = 0;

        


        wait (result_valid_out == 1 && conv_end_out == 1);
        #1; // Small delay to allow output to stabilize
        $display("Initial Test:");
        $display("Input 1        = 0x%h", 32'h00000001);
        // $display("Expected Output= 0x%h", expected_outputs[i]);
        $display("Actual Output  = 0x%b", tanh_result);

        @(posedge clk);
        #1;
        if (result_valid_out == 1 && conv_end_out == 1) begin
            $display("Initial Test:");
            $display("Input 2        = 0x%h", 32'h00000002);
            // $display("Expected Output= 0x%h", expected_outputs[i]);
            $display("Actual Output  = 0x%b", tanh_result);
        end

        // for (i = 0; i < 7; i = i + 1) begin
        //     @(posedge clk);
        //     conv_result = test_inputs[i];
        //     result_valid_in = 1;
        //     conv_end_in = (i == 6);

        //     @(posedge clk);
        //     result_valid_in = 0;
        //     conv_end_in = 0;

        //     // Wait for result_valid_out to go high
        //     wait (result_valid_out == 1);

        //     // Small delay to allow output to stabilize
        //     #1;
        //     $display("Test %0d:", i);
        //     $display("Input          = 0x%h", test_inputs[i]);
        //     $display("Expected Output= 0x%h", expected_outputs[i]);
        //     $display("Actual Output  = 0x%h", tanh_result);

        //     if (abs_diff(tanh_result, expected_outputs[i]) <= 32'h00010000) begin
        //         $display("Result: PASS\n");
        //     end else begin
        //         $display("Result: FAIL\n");
        //     end
        // end

        $display("==== Testbench Complete ====");
        $finish;
    end

endmodule
