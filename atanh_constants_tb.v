`timescale 1ns/1ps
module atanh_constants_tb;

    // Parameter declarations.
    parameter N = 32;
    parameter MEM_SIZE = 32;
    
    // Define a memory (Block RAM) with N-bit words.
    reg [N-1:0] mem [0:MEM_SIZE-1];
    
    // Loop indices and helper variables.
    integer i, j;
    real scale;
    real decimal_value;

    initial begin
        // Compute the scaling factor: scale = 2^N.
        scale = 1.0;
        for (j = 0; j < N; j = j + 1) begin
            scale = scale * 2.0;
        end

        // Load the hexadecimal numbers from the file "atanh_constants.mem"
        // into the memory array.
        $readmemh("atanh_constants.mem", mem);

        // Iterate over each memory location.
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            // Convert the U0.N fixed-point value to a real decimal.
            decimal_value = mem[i] / scale;
            
            // Print the hexadecimal value.
            $display("Hex: %h", mem[i]);

            // Print the binary representation with leading zeros.
            $write("Binary: 0b");
            for (j = N-1; j >= 0; j = j - 1) begin
                $write("%b", mem[i][j]);
            end
            $display("");  // New line.

            // Print the decimal value.
            $display("Decimal: %f\n", decimal_value);
        end

        

        $finish;
    end

endmodule
