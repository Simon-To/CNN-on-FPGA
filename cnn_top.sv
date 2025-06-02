module cnn_top #(
    parameter WIDTH = 16, // Width of the input and output data
    parameter N = 5,    // Side length of original input matrix to Convolution Layer
    parameter K = 3,    // Side length of kernel of Convolution Layer
    parameter S = 1    // Stride size (horizontal stride = vertical stride)
) (
    input clk,
    input reset,
    output [WIDTH-1:0] top_output_result, // Output data from the CNN
    output top_output_valid, // Output valid signal
    output top_output_end // Output end signal
);

    parameter M = (N - K) / S + 1; // Side length of input matrix from convolver
    parameter P = M / 2; // Side length of max-pooled matrix

    // Inputs: Test Input and Kernel Memory
    reg [(WIDTH - 1):0] test_inputs [0:24];
    reg [(K*K*WIDTH-1):0] test_kernel;

    // Index for accessing test inputs
    reg [4:0] input_index;

    // Outputs 
    wire [WIDTH-1:0] cnn_output_result; // Output data from the CNN
    wire cnn_output_valid; // Output valid signal
    wire cnn_output_end; // Output end signal
    
    cnn #(
        .WIDTH(WIDTH),
        .N(N),
        .K(K)
        // .S()
    ) dut (
        // Control Signals
        .clk(clk),
        .clk_en(1'b1), // Clock enable signal
        .glb_rst(reset),

        // Inputs
        .input_val(test_inputs[input_index]),
        .kernel_1d(test_kernel),

        // Outputs
        .output_complete(),
        .output_val(cnn_output_result),
        .valid_out(cnn_output_valid),
        .end_out(cnn_output_end)
    );


    // Input State Machine
    // State Transition Logic
    always@(posedge clk) begin
        if (reset) begin
            input_index <= 0;
        end
        else if (input_index < N*N) begin
            input_index <= input_index + 1;
        end
    end


    // Output Function Logic
    assign top_output_result = cnn_output_result;
    assign top_output_valid = cnn_output_valid;
    assign top_output_end = cnn_output_end;


    // Test Input and Kernel Initialization
    initial begin
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

    end
endmodule