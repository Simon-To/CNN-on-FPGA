`timescale 1ns / 1ps

module tb_max_pooler_2x2;

    parameter WIDTH = 16; // 2^WIDTH = 65536
    // parameter N = 6;  // Input matrix side length
    parameter N = 7;  // Input matrix side length
    parameter K = 3;
    parameter S = 1;

    localparam M = (N - K) / S + 1;
    localparam P = M / 2;
    localparam DATA_COUNT = M * M;

    // Inputs
    reg clk = 0;
    reg clk_en = 1;
    reg glb_rst;
    reg valid_in;
    reg end_in;
    reg signed [WIDTH-1:0] input_val;

    // Outputs
    wire [WIDTH-1:0] output_val;
    wire valid_out;
    wire end_out;
    wire [0:(P*P*WIDTH - 1)] output_complete;

    // Instantiate the DUT
    max_pooler_2x2 #(
        .WIDTH(WIDTH), .N(N), .K(K), .S(S)
    ) DUT (
        .clk(clk),
        .clk_en(clk_en),
        .glb_rst(glb_rst),
        .input_val(input_val),
        .valid_in(valid_in),
        .end_in(end_in),
        .output_val(output_val),
        .valid_out(valid_out),
        .end_out(end_out),
        .output_complete(output_complete)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Input data (example 2D matrix flattened)
    reg signed [WIDTH-1:0] input_matrix [0:DATA_COUNT-1];

    // initial begin
    //     $monitor("Time: %0t, clk: %b, glb_rst: %b, input_val: %d, valid_in: %b, end_in: %b, output_val: %d, valid_out: %b, end_out: %b",
    //              $time, clk, glb_rst, input_val, valid_in, end_in, output_val, valid_out, end_out);
    // end

    integer i;
    initial begin
        // Initialize the input matrix with some known values
        for (i = 0; i < DATA_COUNT; i = i + 1) begin
            input_matrix[i] = $random % 256;
        end

        $display("Input matrix (M = %0d):", M);
        for (i = 0; i < DATA_COUNT; i = i + 1) begin
            $write("%5d ", input_matrix[i]);
            if ((i+1) % M == 0)
                $write("\n");
        end

        // Reset the DUT
        glb_rst = 1;
        valid_in = 0;
        end_in = 0;
        #15;
        glb_rst = 0;
        #10;

        // Apply input values
        for (i = 0; i < DATA_COUNT; i = i + 1) begin
            @(posedge clk);
            input_val <= input_matrix[i];
            valid_in <= 1;
            end_in <= (i == DATA_COUNT - 1);
        end

        // Hold valid low after data input
        @(posedge clk);
        valid_in <= 0;
        input_val <= 0;

        // Wait for end_out
        wait (end_out);
        // @(posedge clk);

        $display("Output Complete Matrix (P = %0d):", P);
        for (i = 0; i < P*P; i = i + 1) begin
            $write("%5d ", $signed(output_complete[((i+1)*WIDTH - 1) -: WIDTH]));
            if ((i+1) % P == 0)
                $write("\n");
        end

        $finish;
    end

endmodule
