// Clock-Gated Version of Max Pooler 2x2

module max_pooler_2x2 #(
    // parameters
    parameter WIDTH = 16, // Width of the input and output data
    parameter N = 8'h0a,    // Side length of input matrix
    parameter K = 8'h03,    // Side length of kernel
    parameter S = 1,        // Stride size (horizontal stride = vertical stride)
) (
    input clk,              // Clock signal
    input clk_en,           // Clock enables
    // reset is async active high
    input glb_rst,          // Global reset signal

    // Output Signals from tanh module
    input wire [(WIDTH - 1):0] tanh_result,// Output of the tanh function in Q1.(WIDTH - 1) signed binary format
    input wire result_valid_in,           // 1-bit valid signal to next layer
    input wire conv_end_in                // 1-bit end signal to next layer


);
    parameter M = (N - K) / S + 1; // Side length of output matrix

    // Instantiate the register for the output
    reg [(WIDTH - 1):0] max_pooler_out_reg [0:(M*M-1)]; 

    wire gated_clk;
    always_comb begin
        if (~clk) begin
            
        end
        else begin
            
        end
    end


endmodule