`timescale 1ns / 1ps
/*
Time unit = 1 ns
Time precision = 1 ps
*/


module cnn_tb;

    // DUT PARAMETER DEFINITION STARTS HERE
    // Bit width:
    parameter WIDTH = 16;
    // Side-length of input matrix (image)
    parameter N = 5;
    // Side-length of kernel
    parameter K = 3;
    // Stride size
    parameter S = 1;
    parameter M = (N - K) / S + 1; // Side length of input matrix from convolver
    parameter P = M / 2; // Side length of max-pooled matrix
    // PARAMETER DEFINITION ENDS HERE

    // DUT INPUTS STARTS HERE
    reg clk;
    reg clk_en;
    reg glb_rst;
    reg [(WIDTH-1):0] input_val;
    reg [(K*K*WIDTH-1):0] kernel_1d;
    // DUT INPUTS ENDS HERE

    // DUT OUTPUTS STARTS HERE
    wire [0:(P*P*WIDTH - 1)] output_complete;
    wire signed [(WIDTH - 1):0] output_val;
    wire valid_out;
    wire end_out;
    // DUT OUTPUTS ENDS HERE

    // CLOCK GENERATION STARTS HERE
    initial clk = 0; // At start of simulation, clk is low
    always #5 clk = ~clk; // 10 ns period = 100 MHz clock
    // CLOCK GENERATION ENDS HERE



    // DUT INSTANTIATION STARTS HERE
    cnn #(
        .WIDTH(WIDTH),
        .N(N),
        .K(K)
        // .S()
    ) dut (
        // Control Signals
        .clk(clk),
        .clk_en(clk_en),
        .glb_rst(glb_rst),

        // Inputs
        .input_val(input_val),
        .kernel_1d(kernel_1d),

        // Outputs
        .output_complete(output_complete),
        .output_val(output_val),
        .valid_out(valid_out),
        .end_out(end_out)
    );
    // DUT INSTANTIATION ENDS HERE

    // { // Input Example 4
    //     {6, 7, 8, 9, 10},
    //     {16, 17, 18, 19, 20},
    //     {1, 2, 3, 4, 5},
    //     {21, 22, 23, 24, 25},
    //     {11, 12, 13, 14, 15}
    // },

    // Test input arrays STARTS HERE
    reg [(WIDTH - 1):0] test_inputs [0:24];
    reg [(K*K*WIDTH-1):0] test_kernel;
    // reg [(WIDTH - 1):0] test_inputs [0:24] = '{
    //     WIDTH'd1, WIDTH'd0, WIDTH'd0, WIDTH'd0, WIDTH'd0,
    //     WIDTH'd0, WIDTH'd0, WIDTH'd0, WIDTH'd0, WIDTH'd1,
    //     WIDTH'd0, WIDTH'd0, WIDTH'd1, WIDTH'd0, WIDTH'd0, 
    //     WIDTH'd1, WIDTH'd0, WIDTH'd0, WIDTH'd0, WIDTH'd0,
    //     WIDTH'd0, WIDTH'd0, WIDTH'd0, WIDTH'd0, WIDTH'd0
    // }; // Holding a 5x5 Input Matrix
    // reg [(K*K*WIDTH-1):0] test_kernel = {
    //     WIDTH'd2, WIDTH'd1, WIDTH'd3, 
    //     WIDTH'd1, WIDTH'd1, WIDTH'd2, 
    //     WIDTH'd1, WIDTH'd3, WIDTH'd2 
    // }; // Holding a 3x3 Input Matrix
    // reg [(K*K*WIDTH-1):0] test_kernel = {
    //     16'h0002, 16'h0001, 16'h0003, 
    //     WIDTH'd1, WIDTH'd1, WIDTH'd2, 
    //     WIDTH'd1, WIDTH'd3, WIDTH'd2 
    // }; // Holding a 3x3 Input Matrix
    reg [(WIDTH - 1):0] expected_outputs;
    // Test input arrays ENDS HERE

    // Error calculation function STARTS HERE
    // function [WIDTH-1:0] abs_diff
    //     input [WIDTH-1:0] a;
    //     input [WIDTH-1:0] b;

    //     begin
    //         if ($signed(a) > $signed(b)) begin
    //             abs_diff = a - b;
    //         end
    //         else begin
    //             abs_diff = b - a;
    //         end
    //     end
    // endfunction
    // Error calculation function ENDS HERE

    // Tests STARTS HERE
    integer i;
    initial begin
        // Input initialization:
        clk = 1;
        clk_en = 1;
        glb_rst = 1;
        input_val = 0;
        kernel_1d = 0;

        // / Wait and release reset
        #20;
        glb_rst = 0;

        test_inputs[0] = 16'd1;
        test_inputs[1] = 16'd0;
        test_inputs[2] = 16'd0;
        test_inputs[3] = 16'd0;
        test_inputs[4] = 16'd0;
        test_inputs[5] = 16'd0;
        test_inputs[6] = 16'd0;
        test_inputs[7] = 16'd0;
        test_inputs[8] = 16'd0;
        test_inputs[9] = 16'd1;
        test_inputs[10] = 16'd0;
        test_inputs[11] = 16'd0;
        test_inputs[12] = 16'd1;
        test_inputs[13] = 16'd0;
        test_inputs[14] = 16'd0;
        test_inputs[15] = 16'd1;
        test_inputs[16] = 16'd0;
        test_inputs[17] = 16'd0;
        test_inputs[18] = 16'd0;
        test_inputs[19] = 16'd0;
        test_inputs[20] = 16'd0;
        test_inputs[21] = 16'd0;
        test_inputs[22] = 16'd0;
        test_inputs[23] = 16'd0;
        test_inputs[24] = 16'd0; // Holding a 5x5 Input Matrix
        test_kernel = {
            16'd2, 16'd1, 16'd3, 
            16'd1, 16'd1, 16'd2, 
            16'd1, 16'd3, 16'd2 
        }; // Holding a 3x3 Input Matrix

        $display("****** Starting CNN Testbench ******");

        
        for (i = 0; i < 25; i++) begin
            @(posedge clk);
            #1;
            input_val = test_inputs[i];
            kernel_1d = test_kernel;

        end

        wait (valid_out && end_out);
        #1;
        $display("Test complete!");
        $display("Actual Output  = 0x%b", output_val);
        
        

    end


endmodule

