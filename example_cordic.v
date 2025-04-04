module cordic_hyperbolic #(
    parameter ITER = 10  // Number of iterations
)(
    input  wire         clk,
    input  wire         rst,
    input  wire         start,
    input  wire [15:0]  in_value,    // Unsigned input (raw binary)
    output reg  [15:0]  tanh_out,    // Result (fixed-point, Q2.14 for example)
    output reg          done
);

  // Internal state encoding
  localparam IDLE    = 2'd0,
             ITERATE = 2'd1,
             FINISH  = 2'd2;
             
  reg [1:0] state;
  reg [3:0] i;  // iteration counter

  // Internal registers.
  // We use Q2.14 for x and y. For z (the residual angle), we use Q1.15.
  // For example, a value of 1.0 in Q2.14 is represented as 16384 (decimal).
  reg signed [15:0] x;  // x in Q2.14
  reg signed [15:0] y;  // y in Q2.14
  reg signed [15:0] z;  // z in Q1.15

  // ---------------------------------------------------------------------
  // ROM for pre-computed arctanh constants (Q1.15 format)
  // In a real design you would load these from an external file.
  reg [15:0] atanh_rom [0:ITER-1];
  initial begin
    // Example (dummy) values in Q1.15 – replace with your precomputed constants.
    atanh_rom[0] = 16'h0C00; // ~atanh(2^-1)
    atanh_rom[1] = 16'h0600; // ~atanh(2^-2)
    atanh_rom[2] = 16'h0300; // ~atanh(2^-3)
    atanh_rom[3] = 16'h0180; // ~atanh(2^-4) (this iteration might be repeated in real designs)
    atanh_rom[4] = 16'h00C0; // ~atanh(2^-5)
    atanh_rom[5] = 16'h0060; // ~atanh(2^-6)
    atanh_rom[6] = 16'h0030; // ~atanh(2^-7)
    atanh_rom[7] = 16'h0018; // ~atanh(2^-8)
    atanh_rom[8] = 16'h000C; // ~atanh(2^-9)
    atanh_rom[9] = 16'h0006; // ~atanh(2^-10)
  end

  // For our purposes, assume that the scaling factor for the whole iteration (in Q2.14)
  // has been precomputed offline. Here we define it as a parameter.
  // (In a complete design, you might store a series of scaling factors and select the one
  // corresponding to the number of iterations.)
  localparam [15:0] SCALING_FACTOR = 16'h0F00; // Example constant in Q2.14

  // ---------------------------------------------------------------------
  // Sign decision: determine d for each iteration.
  // For hyperbolic rotation, if the residual angle z is positive, we subtract the corresponding 
  // constant; if negative, we add it. (d = +1 when z >= 0; d = -1 when z < 0.)
  // Here we produce a signed value d_val.
  reg signed [1:0] d_val;
  always @(*) begin
    if(z[15] == 1'b0)
      d_val = 2'sd1;
    else
      d_val = -2'sd1;
  end

  // ---------------------------------------------------------------------
  // Main state machine for the CORDIC iteration
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state    <= IDLE;
      done     <= 1'b0;
      i        <= 0;
      x        <= 16'd0;
      y        <= 16'd0;
      z        <= 16'd0;
      tanh_out <= 16'd0;
    end else begin
      case (state)
        IDLE: begin
          done <= 1'b0;
          if (start) begin
            // --- Input Conversion ---
            // Convert the unsigned input to fixed-point format.
            // For example, assume 'in_value' is in plain binary and we wish to treat it as Q1.15.
            // In that case, we simply cast it to a signed number.
            // (If further scaling is needed, use a left shift.)
            z <= in_value;  // treat input as the hyperbolic angle in Q1.15

            // Set initial vector values.
            // Typically, for hyperbolic CORDIC in rotation mode, x is set to 1.0 (in Q2.14, that is 16384),
            // and y is set to 0 (or sometimes to a value proportional to the function you wish to compute).
            x <= 16'd16384; // 1.0 in Q2.14
            y <= 16'd0;
            i <= 0;
            state <= ITERATE;
          end
        end
        
        ITERATE: begin
          if (i < ITER) begin
            // Fetch the current arctanh constant from ROM.
            // (For real hardware, you might need to use a separate ROM module.)
            // The constant is in Q1.15.
            // The shifting operations below assume the divisor is 2^i.
            //
            // --- CORDIC Iteration ---
            // The hyperbolic CORDIC update equations are:
            //   x_next = x + d * (y >>> i)
            //   y_next = y + d * (x >>> i)
            //   z_next = z - d * atanh_rom[i]
            // (Note: This is a simplified version and does not include the extra iterations required in hyperbolic mode.)
            x <= x + d_val * (y >>> i);
            y <= y + d_val * (x >>> i);
            z <= z - d_val * atanh_rom[i];
            i <= i + 1;
          end else begin
            // --- Apply Scaling ---
            // In hyperbolic CORDIC, the computed vector is scaled by a constant factor.
            // Multiply the x or y output by the precomputed scaling factor to get the correctly scaled result.
            // Here, we use the scaled y as an approximation of tanh(x) (if x was meant to be 1.0).
            //
            // The multiplication below is between Q2.14 values.
            tanh_out <= (y * SCALING_FACTOR) >>> 14;
            done <= 1'b1;
            state <= FINISH;
          end
        end
        
        FINISH: begin
          // Hold final output until reset.
          state <= FINISH;
        end
        
        default: state <= IDLE;
      endcase
    end
  end

endmodule
