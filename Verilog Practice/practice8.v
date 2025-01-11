module top_module (
    input [4:0] a, b, c, d, e, f,
    output [7:0] w, x, y, z );//

    // assign { ... } = { ... };

    wire [31:0] intermediary;
    assign intermediary = {a[4:0], b[4:0], c[4:0], d[4:0], e[4:0], f[4:0], 2'b11};
    assign z = intermediary[7:0];
    assign y = intermediary[15:8];
    assign x = intermediary[23:16];
    assign w = intermediary[31:24];

    
    

endmodule