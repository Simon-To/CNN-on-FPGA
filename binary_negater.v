module binary_negater #(
    parameter WIDTH = 32 // Bit-width for the input and output data
) (
    input wire signed [(WIDTH - 1):0] in_data, // Input data in signed binary format
    output wire signed [(WIDTH - 1):0] out_data // Output data in signed binary format;
);
    // wire [(WIDTH - 1):0] intermediate; // Invert the input data using bitwise NOT
    // assign intermediate = ~in_data; // Bitwise NOT operation to invert the binary number
    // initial begin
    //     $monitor("~in_data = %b", ~intermediate);
    //     $monitor("out_data = %b", ~intermediate + 1);
    // end
    
    assign out_data = ~in_data + 1; // Two's complement to invert the binary number
    // initial begin
    //     $display("out_data = %b, in_data = %b, inverted = %b", out_data, in_data, ~in_data + 1);
    // end
endmodule