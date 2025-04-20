`timescale 1ns / 1ps

module tb_cordic;

    // Parameters
    parameter WIDTH = 16;
    parameter i = 1;

    // DUT I/O
    reg  signed [WIDTH-1:0] old_x;
    reg  signed [WIDTH-1:0] old_y;
    reg  signed [WIDTH-1:0] old_angle;
    reg         [WIDTH-1:0] atanh;
    
    wire signed [WIDTH-1:0] new_x;
    wire signed [WIDTH-1:0] new_y;
    wire signed [WIDTH-1:0] new_angle;

    // Instantiate the DUT
    cordic #(
        .WIDTH(WIDTH),
        .i(i)
    ) dut (
        .old_x(old_x),
        .old_y(old_y),
        .old_angle(old_angle),
        .atanh(atanh),
        .new_x(new_x),
        .new_y(new_y),
        .new_angle(new_angle)
    );

    // Reference values for one test case
    reg signed [WIDTH-1:0] expected_new_x;
    reg signed [WIDTH-1:0] expected_new_y;
    reg signed [WIDTH-1:0] expected_new_angle;

    // Test task
    task run_test;
        input [WIDTH-1:0] x_in;
        input [WIDTH-1:0] y_in;
        input signed [WIDTH-1:0] angle_in;
        input [WIDTH-1:0] atanh_const;
        input [WIDTH-1:0] x_expected;
        input [WIDTH-1:0] y_expected;
        input signed [WIDTH-1:0] angle_expected;

        begin
            old_x = x_in;
            old_y = y_in;
            old_angle = angle_in;
            atanh = atanh_const;
            expected_new_x = x_expected;
            expected_new_y = y_expected;
            expected_new_angle = angle_expected;

            #5; // Wait for propagation

            $display("TEST CASE:");
            $display("  old_x      = %d", old_x);
            $display("  old_y      = %d", old_y);
            $display("  old_angle  = %d", old_angle);
            $display("  atanh      = %d", atanh);
            $display("  new_x      = %d (expected %d) %s", new_x, expected_new_x, (new_x === expected_new_x) ? "PASSED" : "FAILED");
            $display("  new_y      = %d (expected %d) %s", new_y, expected_new_y, (new_y === expected_new_y) ? "PASSED" : "FAILED");
            $display("  new_angle  = %d (expected %0d) %s", new_angle, expected_new_angle, (new_angle === expected_new_angle) ? "PASSED" : "FAILED");
            $display("");
        end
    endtask

    initial begin
        // =============================
        // Test: i = 1, atanh(2^-1) = arctanh(0.5)
        // atanh = 0.5493 (Q0.16) ≈ 0.5493 * 2^16 ≈ 36004 = 16'h8C44
        // Initial angle = 0 (0 degrees)
        // X = 1.0 = 2^12 = 4096
        // Y = 0
        // Expected direction: +1 (angle < 0 is false)
        // new_x = old_x + y >> 1 = 4096 + 0 = 4096
        // new_y = old_y + x >> 1 = 0 + 2048 = 2048
        // new_angle = old_angle - atanh = 0 - 36004 = -36004
        // =============================

        run_test(
            16'd4096,         // old_x = 1.0 in Q4.12
            16'd0,            // old_y = 0
            16'd0,            // old_angle = 0
            16'd36004,        // atanh ≈ 0.5493
            16'd4096,         // expected new_x
            16'd2048,         // expected new_y = 0.5
            -16'd1       // expected new_angle
        );

        #10

        run_test(
            -16'd22249,         // old_x = -5.432 in Q4.12
            16'd14156,            // old_y = 6.789 in Q4.12
            -16'd3456,            // old_angle = -3456
            16'd22654,        // atanh ≈ 0.34567
            -16'd29327,         // expected new_x = -7.16
            16'd25280,         // expected new_y = 6.172
            -16'd3456       // expected new_angle = -3456
        );



        // Add more test cases here for negative angles and i = 2, 3, etc.

        $display("All tests completed.");
        $finish();
    end

endmodule
