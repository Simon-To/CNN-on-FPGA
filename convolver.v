// Module declaration with inputs and outputs
module convolution #( // Declaring convolution as a parameterized module
    // Parameter list BEGINS
    parameter N = 8'h0a,    // Side length of input matrix
    parameter K = 8'h03,    // Side length of kernel
    parameter S = 1,        // Stride size (horizontal stride = vertical stride)
    parameter WIDTH = 16,   // Width of the bits used
    parameter Q = 12        // Number of fractional bits in the case of fixed point
    // Parameter list ENDS
)(
    input clk,              // Clock signal
    input clk_en,           // Clock enables
    input glb_rst,          // Global reset signal
    input [WIDTH-1:0] activation,   // An element in input matrix
    output wire [N-1:0] 
    input wire reset,        // Reset signal
    input wire [3:0] in,     // 4-bit input
    output reg [3:0] out     // 4-bit output
);

// Internal signals
reg [3:0] temp_reg;

// Always block triggered by the rising edge of the clock or reset
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Synchronous reset logic
        out <= 4'b0000;
        temp_reg <= 4'b0000;
    end else begin
        // Main logic
        temp_reg <= in;
        out <= temp_reg;
    end
end


endmodule