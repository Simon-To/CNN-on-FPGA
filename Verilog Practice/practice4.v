module top_module( 
    input [31:0] in,
    output [31:0] out );//

    // assign out[31:24] = ...;

    // integer i;
    // integer j;
    
    // always @(*) begin
    //     for (i = 0; i < 4; i = i + 1) begin
    //         for (j = 0; j < 8; j = j + 1) begin

    //             if (in[8 * (i + 1) - 1 - j]) begin
    //                 out[8 * (4 - i) - 1 - j] = in[8 * (i + 1) - 1 - j];  
    //             end
    //         end 

    //     end
    // end

    // https://hdlbits.01xz.net/wiki/Vectorgates

endmodule