# CNN-on-FPGA
Running a deployed Convolutional Neural Network on FPGA


## Update 09/23
- Completed C++-based algorithm verification for Hyperbolic Tangent (tanh) powered by CORDIC.
- Main concern lies in CORDIC's ability to estimate tanh(theta) where tanh(theta) is outside the range of [-2^-i, 2^-i]
  - After investigation, the reason of this issue is caused by the limitation of CORDIC algorithm. Since we restricted theta in range [-1, 1]
- This concern might be solved by double iteration:
  - Double iteration can be implemented by creating a nested loop of two iterations within each outer iteration.
  - In my code implementation, I used the aforementioned "nested loop" method to implement two-iteration CORDIC.
    - The result are quite satisfactory: After sweeping theta from -2^j to 2^j where j goes from -24 to 24 inclusive:
      - tanh(theta) estimation value are very accurate and precise until when |theta| >= 2^3, where the estimated tanh(theta) plateaus at +/-0.971075 instead of being rounded to +/-1
      - This can be significantly improved if we implement three-iteration CORDIC. (This is verified to be true)
      - **Whether three-iteration approach is efficient enough to be adopted in FPGA CNN depends on next step.**

## Next step
1. Read through the guide on CORDIC Verilog implementation. 
2. Find how to implement our two-iteration CORDIC efficiently.
3. Explore possibility of three- or even more iteration CORDIC.


