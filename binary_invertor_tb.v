`timescale 1ns / 1ps

module tb_binary_invertor;

    parameter WIDTH = 32;

    // Testbench signals
    reg signed [WIDTH-1:0] in_data;
    wire signed [WIDTH-1:0] out_data;

    // Instantiate the DUT (Device Under Test)
    binary_invertor #(.WIDTH(WIDTH)) uut (
        .in_data(in_data),
        .out_data(out_data)
    );

    // Task to perform a single test
    task check_result;
        input signed [WIDTH-1:0] test_val;
        begin
            in_data = test_val;
            #1; // Wait 1 time unit for result to propagate
            if (out_data !== -in_data) begin
                $display("ERROR: in_data = %0d, out_data = %0d, expected = %0d", in_data, out_data, -in_data);
            end else begin
                $display("PASS:  in_data = %0d, out_data = %0d", in_data, out_data);
            end
        end
    endtask

    initial begin
        $display("Starting binary_invertor testbench...");

        // Test zero
        check_result(0);

        // Test positive numbers
        check_result(1);
        check_result(1234);
        check_result(2**(WIDTH-2)); // Large positive number

        // Test negative numbers
        check_result(-1);
        check_result(-5678);
        check_result(-2**(WIDTH-2)); // Large negative number

        // Test maximum and minimum signed values
        check_result($signed(2**(WIDTH-1) - 1)); // Max signed value
        check_result($signed(-(2**(WIDTH-1))));  // Min signed value

        // Test a few random values
        repeat (10) begin
            check_result($random);
        end

        $display("All tests completed.");
        $finish;
    end

endmodule
