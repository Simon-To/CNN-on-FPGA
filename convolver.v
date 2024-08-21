// Module declaration with inputs and outputs
module my_module (
    input wire clk,          // Clock signal
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