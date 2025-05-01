module max_pooler_2x2 #(
    // parameters
    parameter WIDTH = 16, // Width of the input and output data
    parameter N = 8'h0a,    // Side length of original input matrix to Convolution Layer
    parameter K = 8'h03,    // Side length of kernel of Convolution Layer
    parameter S = 1        // Stride size (horizontal stride = vertical stride)
) (
    input clk,              // Clock signal
    input clk_en,           // Clock enables
    // reset is async active high
    input glb_rst,          // Global reset signal

    // Output Signals from tanh module
    input wire signed [(WIDTH - 1):0] input_val,// Output of the tanh function in Q1.(WIDTH - 1) signed binary format
    input wire valid_in,           // 1-bit valid signal to next layer
    input wire end_in,                // 1-bit end signal to next layer

    
    // Flattened max_pool[0:(P*P-1)] to output_complete[0:(P*P*WIDTH - 1)]
    output wire [0:(P*P*WIDTH - 1)] output_complete, // Output of the max pooling operation
    output wire signed [(WIDTH - 1):0] output_val, // Output of the max pooling operation
    output wire valid_out,          // 1-bit valid signal to next layer
    output wire end_out             // 1-bit end signal to next layer
);
    parameter M = (N - K) / S + 1; // Side length of input matrix from convolver
    parameter P = M / 2; // Side length of max-pooled matrix
    parameter SKIP_NECESSARY = (M % 2 == 0) ? 1'b0 : 1'b1; // Skip the last row/column if M is odd
    localparam MP_ADDR_WIDTH = $clog2(P*P);
    localparam CONV_ADDR_WIDTH = $clog2(M*M);
    localparam SKIP_ADDR_WIDTH = $clog2(M);
    localparam SKIP_INDEX = M - 1;

    localparam EFFECTIVE_M = SKIP_NECESSARY ? M - 1 : M; // Effective side length of input matrix

    
    // Step 1: Instantiate the register for the output
    reg signed [(WIDTH - 1):0] max_pool [0:(P*P-1)];
    // This reg-type variable should NOT be interpreted as a register by synthesis tools
    reg [0:(P*P*WIDTH - 1)] output_complete_reg;
    reg [(WIDTH - 1):0] output_val_reg;
    reg valid_out_reg;
    reg end_out_reg;
    
    
    // Step 2: Calculate the address of current entry and get the 
    // current occupant in the max pooling matrix.
    reg [(CONV_ADDR_WIDTH - 1):0] input_counter;
    reg [(SKIP_ADDR_WIDTH - 1):0] skip_counter;
    // For valid_out_counter, we need to be able to count from 0 to M - 1 + 2,
    // so we need to use SKIP_ADDR_WIDTH + 1 bits.
    // reg [((SKIP_ADDR_WIDTH + 1) - 1):0] valid_out_counter;
    // reg skip_flag;
    
    wire [(SKIP_ADDR_WIDTH - 1):0] x_m = input_counter % EFFECTIVE_M;
    wire [(SKIP_ADDR_WIDTH - 1):0] y_m = input_counter / EFFECTIVE_M;

    wire [(MP_ADDR_WIDTH - 1):0] x_p = x_m / 2; // TODO: Change to bit shift!
    wire [(MP_ADDR_WIDTH - 1):0] y_p = y_m / 2; // TODO: Change to bit shift!

    wire [(MP_ADDR_WIDTH - 1):0] max_pool_addr = y_p * 2 + x_p; // TODO: Change to bit shift!

    wire signed [(WIDTH - 1):0] current_max = max_pool[max_pool_addr];

    wire new_max = ($signed(input_val) > $signed(current_max)) ? 1'b1 : 1'b0;

    // We skip if:
    // 1. We have an odd M, which means skip is necessary
    // 2. We are at the last column of the input matrix, which means skip_counter == SKIP_INDEX
    // 3. We are at the last row of the input matrix, which means y_m == SKIP_INDEX
    wire skip = ((SKIP_NECESSARY) && ((skip_counter == SKIP_INDEX) || (y_m == SKIP_INDEX))) ? 1'b1 : 1'b0;

    // Step 3: Combinational assignment of the output
    assign output_val = output_val_reg;
    assign valid_out = valid_out_reg;
    assign end_out = end_out_reg;
    assign output_complete = output_complete_reg;
    // If the Input Matrix index of the incoming data is at
    // an ODD row AND an ODD column, then that means this data
    // belongs to the last (bottom-right) element of a 2x2 max-pooling
    // window. This means whatever the max value in max_pool's
    // max_pool_addr entry is at the end of this clock cycle, it
    // should be the max value of the entire 2x2 max-pooling window.
    // Therefore, we should set the valid_out signal to 1 in the next clock cycle.
    assign valid_out_next_clk = x_m[0] && y_m[0];
    always @(*) begin
        integer i;
        for (i = 0; i < P*P; i = i + 1) begin
            output_complete_reg[((i+1)*WIDTH - 1) -: WIDTH] = max_pool[i];
            // output_complete_reg[i*WIDTH +: WIDTH] = max_pool[i];
        end
    end




    integer i;
    always@(posedge clk) begin
        // if (I need to reset):
        if (glb_rst) begin // Synchronous High-Active Reset
            // Reset all registers to smallest representable value
            // set the result_ready signal to 0
            for (i = 0; i < P*P; i = i + 1) begin
                max_pool[i] <= {1'b1, {(WIDTH - 1){1'b0}}};
            end
            // skip_flag <= 1'b0;
            skip_counter <= 0;
            input_counter <= 0;
        end
        else if (clk_en) begin
            // ((a valid data came in) && (this data is greater than the current max)):
            end_out_reg <= end_in;
            if (valid_in) begin
                // This is a valid input data
                // Should we skip this input data?
                if (skip) begin
                    if (y_m != SKIP_INDEX) begin
                        // We don't have to reset skip_counter
                        // if we are at the last row
                        skip_counter <= 0;
                    end
                    input_counter <= input_counter;
                end
                else begin
                    skip_counter <= skip_counter + 1;
                    input_counter <= input_counter + 1;
                    if (new_max) begin
                        // Update the current max
                        max_pool[max_pool_addr] <= input_val;
                    end
                end

                // Should we set the valid_out signal to 1?
                if (valid_out_next_clk) begin
                    // This is the last data in this max-pooling window
                    valid_out_reg <= 1'b1;
                    // Output the max value in this max-pooling window
                    output_val_reg <= new_max ? input_val : max_pool[max_pool_addr];
                end
                else begin
                    // This is not the last data in the max-pooling window
                    valid_out_reg <= 1'b0;
                end

            end
        end
    end

    initial begin
        $monitor("Time: %0t, clk: %b, glb_rst: %b, input_val: %d, EFFECTIVE_M: %d, x_m: %d, y_m: %d, input_counter: %d,valid_in: %b, end_in: %b, output_val: %d, valid_out: %b, end_out: %b",
                 $time, clk, glb_rst, input_val, EFFECTIVE_M, x_m, y_m, input_counter, valid_in, end_in, output_val, valid_out, end_out_reg);
    end

endmodule
    /*
    max_pooler_2x2 functionality:
    When it's no longer RESET, and the Clock Enable is HIGH:
        
        If valid_in is high, then the input_val is valid.
        Valid data need NOT be provided for every clock cycle.
        We should only treat the data as valid if valid_in is high.

        We should then check if we need to skip this data.
        If the M, the side length of the input matrix, is odd,
        then we need to skip the last row and the last column.
        We facilitate this by using a skip_counter to check if
        the incoming data come from the last column of the input
        matrix, and we use the y_m to check if the incoming data
        come from the last row of the input matrix.

        Whenever a max-pooling window is completed, we should
        set the valid_out signal to 1, and output the max value
        of the max-pooling window to the output_val signal.

        At the end, when end_out is high, we should be able to 
        see the entire max-pooled matrix from the output_complete
        output signal.

    Please create a Verilog testbench to thoroughly test this
    module. Let me know if you have any questions.
    */

    /*
    sequentially clocked always block:
        if (I need to reset):
            reset all registers to smallest representable value
            set the result_ready signal to 0
        else if (
        a valid data came in && 
        this data is greater than the current max):
            update the current max
            if this is the last data in the matrix:
                set the result_ready signal to 1
            else:
                set the result_ready signal to 0
        else:
            keep the current max
            set the result_ready signal to 0



            Input matrix (M = 5):
            36  -127  -247  -157    13 
            141  -155  -238     1    13 
            118    61   237   140   249 
            -58   -59   -86   229  -137 
            -238   143   242   -50   -24 

               36  -127  -247  -157    13 
            141  -155  -238     1    13 
            118    61   237   140   249 
            -58   -59   -86   229  -137 
            -238   143   242   -50   -24 

            141     1 
            118   237 
    */
    
    


