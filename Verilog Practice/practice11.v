module top_module (
    input a, b, c, d, e,
    output [24:0] out );//

    // The output is XNOR of two vectors created by 
    // concatenating and replicating the five inputs.
    // assign out = ~{ ... } ^ { ... };
    
    wire [24:0] aaaaa = {{5{a}}, {5{b}}, {5{c}}, {5{d}}, {5{e}}};

    wire [24:0] abcde = {{a, b, c, d, e}, {a, b, c, d, e}, {a, b, c, d, e}, {a, b, c, d, e}, {a, b, c, d, e}};

    always @(*) begin
        for (int i=0; i<25; ++i) begin
            out[i] = ~aaaaa[i] ^ abcde[i];
        end
    end

endmodule