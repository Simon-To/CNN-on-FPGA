/*
module convolution #( // Declaring convolution as a parameterized module
    // Parameter list BEGINS
    parameter N = 8'h0a,    // Side length of input matrix
    parameter K = 8'h03,    // Side length of kernel
    parameter S = 1,        // Stride size (horizontal stride = vertical stride)
    parameter WIDTH = 16,   // Width of the bits used
    parameter Q = 12,       // Number of fractional bits in the case of fixed point
    parameter padding = 1   // Use padding or not
    // Parameter list ENDS
)(
    input clk,              // Clock signal
    input clk_en,           // Clock enables
    // reset is async active high
    input glb_rst,          // Global reset signal

    // Notice that the kernel matrix is flattened into a 1D array
    // There are K*K elements in the kernel
    // Each element is of WIDTH bits
    // In total, there are K*K*WIDTH bits in the kernel matrix
    input [(WIDTH-1):0] input_val, // ONE element of the input matrix
    input [(K*K*WIDTH-1):0] kernel_1d, // 1D version of the kernel matrix

    output [WIDTH-1:0] conv_result, // Output of the convolution
    output result_valid, // Output signal to indicate that the result is valid
    output conv_end // End of convolution signal
);




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





module max_pooler_2x2 #(
    // parameters
    parameter WIDTH = 16, // Width of the input and output data
    parameter N = 8'h0a,    // Side length of original input matrix to Convolution Layer
    parameter K = 8'h03,    // Side length of kernel of Convolution Layer
    parameter S = 1        // Stride size (horizontal stride = vertical stride)
) (
    input clk,              // Clock signal
    input clk_en,           // Clock enables
    // reset is async active high
    input glb_rst,          // Global reset signal

    // Output Signals from tanh module
    input wire signed [(WIDTH - 1):0] input_val,// Output of the tanh function in Q1.(WIDTH - 1) signed binary format
    input wire valid_in,           // 1-bit valid signal to next layer
    input wire end_in,                // 1-bit end signal to next layer

    
    // Flattened max_pool[0:(P*P-1)] to output_complete[0:(P*P*WIDTH - 1)]
    output wire [0:(P*P*WIDTH - 1)] output_complete, // Output of the max pooling operation
    output wire signed [(WIDTH - 1):0] output_val, // Output of the max pooling operation
    output wire valid_out,          // 1-bit valid signal to next layer
    output wire end_out             // 1-bit end signal to next layer
);

*/

module cnn #(
    // parameters
    parameter WIDTH = 16, // Width of the input and output data
    parameter N = 8'h0b,    // Side length of original input matrix to Convolution Layer
    parameter K = 8'h03,    // Side length of kernel of Convolution Layer
    parameter S = 1        // Stride size (horizontal stride = vertical stride)
) (
    input clk,              // Clock signal
    input clk_en,           // Clock enables
    // reset is async active high
    input glb_rst,          // Global reset signal

    // Notice that the kernel matrix is flattened into a 1D array
    // There are K*K elements in the kernel
    // Each element is of WIDTH bits
    // In total, there are K*K*WIDTH bits in the kernel matrix
    input [(WIDTH-1):0] input_val, // ONE element of the input matrix
    input [(K*K*WIDTH-1):0] kernel_1d, // 1D version of the kernel matrix
    // CNN: Please read kernel values from the memory (Load to BRAM)

    // CNN: Also store output values to the memory (Store to BRAM, then write to output file)
    // Flattened max_pool[0:(P*P-1)] to output_complete[0:(P*P*WIDTH - 1)]
    // Complete output of the max pooling operation
    // Provided when max-pooling of the entire input matrix is done
    output wire [0:(P*P*WIDTH - 1)] output_complete, 
    // Single output of the max pooling operation
    // Provided whenever valid_out is 1
    output wire signed [(WIDTH - 1):0] output_val, 
    output wire valid_out,          // 1-bit valid signal to next layer
    output wire end_out             // 1-bit end signal to next layer
);

// Constants calculation
// STARTS HERE
parameter M = (N - K) / S + 1; // Side length of input matrix from convolver
parameter P = M / 2; // Side length of max-pooled matrix
// Constants calculation
// ENDS HERE

// Interface between Convolution Layer and Non-Linearity Layer
// STARTS HERE
wire [WIDTH-1:0] conv_result; // Output of the convolution
wire conv_result_valid; // Output signal to indicate that the result is valid
wire conv_end; // End of convolution signal
// Interface between Convolution Layer and Non-Linearity Layer
// ENDS HERE


// Convolution Layer Instantiation
// STARTS HERE
convolution #(
    .N(N),
    .K(K),
    .S(S),
    .WIDTH(WIDTH)
) convolution_layer (
    // Control Signals
    .clk(clk), // Clock signal
    .clk_en(clk_en), // Clock enables
    .glb_rst(glb_rst), // Global reset signal

    // Inputs
    .input_val(input_val), // ONE element of the input matrix
    .kernel_1d(kernel_1d), // 1D version of the kernel matrix

    // Outputs
    .conv_result(conv_result),
    .result_valid(conv_result_valid),
    .conv_end(conv_end)
);
// Convolution Layer Instantiation
// ENDS HERE


// Interface between Non-Linearity Layer and Max-Pooling Layer
// STARTS HERE
wire [WIDTH-1:0] tanh_result; // Output of the convolution
wire tanh_result_valid; // Output signal to indicate that the result is valid
wire tanh_end; // End of convolution signal
// Interface between Non-Linearity Layer and Max-Pooling Layer
// ENDS HERE


// Non-Linearity Layer Instantiation
// STARTS HERE
tanh #(
    .WIDTH(WIDTH)
) non_linearity_layer (
    // Control Signals
    .clk(clk), // Clock signal
    .clk_en(clk_en), // Clock enables
    .glb_rst(glb_rst), // Global reset signal

    // Inputs
    .conv_result(conv_result),
    .result_valid_in(conv_result_valid),
    .conv_end_in(conv_end),

    // Outputs
    .tanh_result(tanh_result),
    .result_valid_out(tanh_result_valid),
    .conv_end_out(tanh_end)
);
// Non-Linearity Layer Instantiation
// ENDS HERE


// Max-Pooling Layer Instantiation
// STARTS HERE
max_pooler_2x2 #(
    .WIDTH(WIDTH),
    .N(N),
    .K(K),
    .S(S)
) max_pooling_layer (
    // Control Signals
    .clk(clk),
    .clk_en(clk_en),           // Clock enables
    .glb_rst(glb_rst),          // Global reset signal

    // Inputs
    .input_val(tanh_result),
    .valid_in(tanh_result_valid),
    .end_in(tanh_end),

    // Outputs
    .output_complete(output_complete),
    .output_val(output_val),
    .valid_out(valid_out),
    .end_out(end_out)
);

// Max-Pooling Layer Instantiation
// ENDS HERE

endmodule