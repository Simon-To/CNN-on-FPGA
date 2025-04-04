// Module declaration with inputs and outputs
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

// PART 1: Instatiation Statements STARTS HERE

// Instantiation of kernel_2d: Conversion of Kernel from 1D to 2D
// Note that the structure of the so-called 2D kernel is a
// 1D array of KxK elements, where each element is of 
// [(WIDTH-1):0] wide.
wire [(WIDTH - 1):0] kernel_2d [0:(K * K - 1)];
generate
	genvar n;
    for (n=0; n<(K*K); n=n+1) 
    begin
        // Syntax explanation:
        // Selecting WIDTH bits inclusively, starting from the bit position (WIDTH * l)
        assign kernel_2d[n][WIDTH-1:0] = kernel_1d[(WIDTH * n) +: WIDTH];
    end
endgenerate

// Instantiation of shift_reg vector:
// Size of shift_reg:
// - x1 element to store 0 for all times as the input to the first MAC unit.
//  - Located at the Top left corner of Active Section
// - x((K - 1) * N) elements to act as shift register of the top (K-1)
// rows of the Active Section and the entirety of the Dormant Section 
//  - Constitute the main body of the array
// - xK elements to store the LAST row of the Active Section 
// TOTAL SIZE = 1 + ((K - 1) * N) + K
// So, the range is 0 to ((K - 1) * N) + K inclusive

// Each element of shift_reg is a series of binary of size:
// [(WIDTH-1):0]

// 2025/04/03: Change width of registers and wires to (2 * WIDTH - 1)
// to reflect the
reg [WIDTH-1:0] shift_reg [0:(((K - 1) * N) + K)];

// Initialize wires that leads to each of the element within register array
// except the 0-indexed one.
wire [WIDTH-1:0] reg_wire_to [0:(((K - 1) * N) + K)];

reg result_valid_reg;
reg conv_end_reg;

// PART 1: Instatiation Statements ENDS HERE




// PART 2: Spatial traversal for operation definition STARTS HERE

// More specifically, in this part, we go over the entire shift_reg array
// to specify where Active Section and Dormant Section are located, and 
// generate the hardware need to do what should be done in each section.

// Notice that the shift_reg array is inherently a 1D array. This means
// we have to keep track of where we are in the conceptually 2D array.

// Initial Section: The first element of the shift_reg array
// This should contain the value 0 at all times to be used as the input
// to the first MAC unit.
// assign shift_reg[0] = 'd0;

// Register Array Exit Point: The last element of the shift_reg array 
// should be the output of the entire Convolution operation.
                            //    1 + ((K - 1) * N) + K
assign conv_result = shift_reg[((K - 1) * N) + K];


// Convolution Final Exit Point: The current input element is the last
// in the input matrix. The Convolution operation is ending.
assign conv_end = conv_end_reg;

assign result_valid = result_valid_reg;




generate
    genvar k; // Indexing which ROW of the register array we're situated in.
    genvar l; // Indexing which COLUMN of the register array we're situated in.

    for (k=0; k < K; k=k+1) 
    begin // For each row of shift_reg
        
        for (l=0; l < N; l=l+1) 
        begin // For each element of shift_reg
            
            // ACTIVE SECTION OPERATIONS STARTS HERE
            // if ((k >= 0 && k <= (Convolver::K - 1)) && (l >= 0 && l <= (Convolver::K - 1))) {
            if ((k >= 0 && k <= (K - 1)) && (l >= 0 && l <= (K - 1))) 
            begin // We're in the Active Section
                if (l == 0) 
                begin // At the left-most column of the register array
                    if (k == 0) begin
                        // Special Case 1: Top Left element of the register array
                        
                        // IMPORTANT DISCUSSION: How do we arrive at the location in the 
                        // shift register array with k and l?
                        // shift_reg index = 1 + (k * N) + l
                        // kernel_2d index = k * K + l
                        mac_unit #(
                            .M(WIDTH),
                            .Q(Q)
                        ) spec_case_1 (
                            .clk(clk),
                            .rst(glb_rst),
                            .clk_en(clk_en),
                            .a(kernel_2d[k * K + l]),
                            .b(input_val),
                            .c(shift_reg[0]),
                            .out(reg_wire_to[1 + (k * N) + l])
                        );
                    end
                    else 
                    begin
                        // Special Case 3: Non-top Left-most element of the register array
                        // Access the right-most register in the previous row.
                        // right-most register of previous row index = 1 + ((k - 1) * N) + (N - 1)
                        mac_unit #(
                            .M(WIDTH),
                            .Q(Q)
                        ) spec_case_3 (
                            .clk(clk),
                            .rst(glb_rst),
                            .clk_en(clk_en),
                            .a(kernel_2d[k * K + l]),
                            .b(input_val),
                            .c(shift_reg[1 + ((k - 1) * N) + (N - 1)]),
                            .out(reg_wire_to[1 + (k * N) + l])
                        );
                    end
                end
                // ((k == (Convolver::K - 1)) && (l == (Convolver::K - 1)))
                else if ((k == (K - 1)) && (l == (K - 1)))
                begin
                    // Special Case 2: Bottom Right element of the register array
                    mac_unit #(
                        .M(WIDTH),
                        .Q(Q)
                    ) spec_case_2 (
                        .clk(clk),
                        .rst(glb_rst),
                        .clk_en(clk_en),
                        .a(kernel_2d[k * K + l]),
                        .b(input_val),
                        .c(shift_reg[(k * N) + l]),
                        .out(reg_wire_to[((K - 1) * N) + K])
                        // Output goes straight to the output of the module via the last element
                        // 1 + ((K - 1) * N) + (K - 1)
                        // (((K - 1) * N) + K)
                        // (((K - 1) * N) + K)
                    );

                    // Note that the validity of the result is disambiguated by the result_valid 
                    // signal, which will be produced by Part 3 (Temporal traversal for output 
                    // element identification)

                end
                else 
                begin
                    // Normal Case: Any other element in the register array
                    mac_unit #(
                        .M(WIDTH),
                        .Q(Q)
                    ) normal_case (
                        .clk(clk),
                        .rst(glb_rst),
                        .clk_en(clk_en),
                        .a(kernel_2d[k * K + l]),
                        .b(input_val),
                        .c(shift_reg[(k * N) + l]),
                        .out(reg_wire_to[1 + (k * N) + l])
                        // Output goes straight to the output of the module via the last element
                        // 1 + ((K - 1) * N) + (K - 1)
                        // (((K - 1) * N) + K)
                        // (((K - 1) * N) + K)
                    );
                end
                always @(posedge clk or posedge glb_rst) begin
                    if (glb_rst) // Global Reset is active, reset all bits
                    begin
                        shift_reg[1 + (k * N) + l] <= 1'b0; // Reset each bit
                    end 
                    
                    else if (clk_en)
                    begin // Clock is enabled, shift the data
                        shift_reg[1 + (k * N) + l] <= reg_wire_to[1 + (k * N) + l]; // Store data
                    end
                end
                
            end
            // ACTIVE SECTION OPERATIONS ENDS HERE

            
            
            // DORMANT SECTION OPERATIONS STARTS HERE
            else 
            begin
                always @(posedge clk or posedge glb_rst) begin
                    if (glb_rst) // Global Reset is active, reset all bits
                    begin
                        if ((1 + (k * N) + l) <= (((K - 1) * N) + K)) begin
                            shift_reg[1 + (k * N) + l] <= 1'b0; // Reset each bit
                        end
                    end 
                    
                    else if (clk_en)
                    begin // Clock is enabled, shift the data
                        if ((1 + (k * N) + l) <= (((K - 1) * N) + K)) begin
                            shift_reg[1 + (k * N) + l] <= shift_reg[(k * N) + l]; // Store data
                        end
                    end
                end
            end
            // DORMANT SECTION OPERATIONS ENDS HERE

        end
        
    end
endgenerate

// PART 2: Spatial traversal for operation definition ENDS HERE

// PART 3: Temporal traversal for output element identification STARTS HERE
// In this part, we have to check if the conv_result at THIS VERY CLOCK is 
// valid or not. This is done by checking if the current input element that 
// is being processed is located at the bottom right corner of the a valid 
// kernel matrix location.

// Firstly, we need a main counter to keep track of the clock cycles.
// The width of this counter should be identical to the total number of
// bit required to index every element of the input matrix.
// This is given by log_2(N * N)
reg [($clog2(N * N) - 1):0] clock_cycle_counter; // 
reg [($clog2(N * N) - 1):0] i;
reg [($clog2(N * N) - 1):0] j;
reg [($clog2(N * N) - 1):0] output_row;

// Now, How do we DERIVE the index of the current element in the input matrix
// from the clock_cycle_counter?
// At reset, both i (row index) and j (column index) are initialized to 0. 
// i increments by 1 after every N clocks, because that's when a whole row of 
// the input matrix is provided.
// j increments by 1 after EVERY clock, because that's when a new element within
// the input matrix is provided. However, j is reset to 0 after every N clocks.
// Because j must be wrapped around after the end of every row.
// j increments by 1 after every clock.

// NOTE: The output can only be produce at the start of the next clock cycle,
// NOT the current one. This is because the output is produced by the MAC unit.
integer r; // Loop variable
integer w; // Loop variable
always @(posedge clk) begin
    if (glb_rst) 
    begin
        // Initialize i and j, the spatial indices of the input matrix derived 
        // from temporal progression.
        i <= 0;
        j <= 0;
        
        // Initialize output signals:
        // conv_result <= {WIDTH{1'b0}}; // Set all WIDTH bits of the output to 0
        result_valid_reg <= 1'b0; // Set the result_valid signal to 0
        conv_end_reg <= 1'b0; // Set the end of convolution signal to 0

        // Initialize the register array to 0
        for (r = 0; r < (1 + ((K - 1) * N) + K); r = r + 1) 
        begin
            shift_reg[r] <= {WIDTH{1'b0}}; // Set all WIDTH bits of row i to 0
        end

    end
    else if (clk_en) 
    begin
        // Notice that we skip the 0th register because it's always 0
        // for (w = 1; w < (1 + ((K - 1) * N) + K); w = w + 1)
        // begin
        //     shift_reg[w] <= reg_wire_to[w];
        // end

        // Indices i and j update rules:
        j <= j + 1;

        if (j == (N - 1)) begin
            // Wrapping imminent for j 
            j <= 0;
            i <= i + 1;
        end

        // conv_end update rules:
        if (
            (i == (N - 1)) &&
            (j == (N - 1))
        ) 
        begin
            conv_end_reg <= 1'b1;
        end
         

        // result_valid update rules:
        if (
            // Check if the current output should be a part of the output
            // The top-left of the current kernel is located at a valid stride
            (((i - (K - 1)) % S) == 0) &&
            (((j - (K - 1)) % S) == 0)
        ) 
        begin
            // The current element is a part of the output
            // $display("We are here.");
            output_row <= $signed((i - (K - 1)) / S);
            if (
                ($signed((i - (K - 1)) / S) >= 0) &&
                ($signed((j - (K - 1)) / S) >= 0)
            ) 
            begin
                result_valid_reg <= 1'b1;
            end
            else 
            begin
                // $display("Are we ever here?");
                result_valid_reg <= 1'b0;
            end
            
            // How do we calculate the target location in the output matrix 
            // where we should put the output in?
            // We actually DO NOT need to worry about it because the output 
            // is directly outputted to the outside scope.
            // POTENTIAL IMPROVEMENT: output the index of the output element
            // within the output matrix as well.
        end
        else 
        begin
            // $display("But are we ever here?");
            result_valid_reg <= 1'b0;
        end

    end
end

// PART 3: Temporal traversal for output element identification ENDS HERE

// initial begin
//     $display("Simulation started");
// end

// initial begin
//     $monitor("Time: %0t | clk: %b | kernel_1d: %d | input_val: %d | i: %d | j: %d | conv_result: %0d | result_valid_reg: %0d | conv_end: %0d", 
//                 $time, clk, kernel_1d, input_val, i, j, conv_result, result_valid_reg, conv_end);
// end

// .a(kernel_2d[k * K + l]),
// .b(input_val),
// .c(shift_reg[(k * N) + l]),
// .out(reg_wire_to[((K - 1) * N) + K])

// Convolver test output
// initial begin
//     $monitor(
//         "Time: %0t | clk: %b | kernel_2d[2]: %d | input_val: %d | shift_reg[2]: %d | shift_reg[3]: %d | reg_wire_to[3]: %d | shift_reg[4]: %d | conv_result: %0d | result_valid_reg: %0d | conv_end: %0d", 
//         $time, clk, kernel_2d[2], input_val, shift_reg[2], shift_reg[3], reg_wire_to[3], shift_reg[4], conv_result, result_valid_reg, conv_end);
// end


endmodule