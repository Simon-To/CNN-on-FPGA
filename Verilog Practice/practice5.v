module top_module( 
    input [2:0] a,
    input [2:0] b,
    output [2:0] out_or_bitwise,
    output out_or_logical,
    output [5:0] out_not
);

    // Build a circuit that has two 3-bit inputs that computes the bitwise-OR of the two vectors, 
    // the logical-OR of the two vectors, and the inverse (NOT) of both vectors. Place the inverse 
    // of b in the upper half of out_not (i.e., bits [5:3]), and the inverse of a in the lower half.

    // bitwise-OR
    always @(*) begin
        out_or_logical = a[2] & a[1] & a[0] & b[2] & b[1] & b[0]
        for (i = 0; i < 3; i = i + 1) begin
            out_or_bitwise[i] = a[i] || b[i];
        end

        for (i = 0; i < 2; i = i + 1) begin
            for (j = 0; j < 3; j = j + 1) begin
                out_not[3 * i + j] = a[j]; 
            end 

        end

        

        


        


    end



endmodule