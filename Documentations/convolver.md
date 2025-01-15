# Convolver
Document the development of Convolution Layer of CNN.


## Logic Verification in C++
- What is Convolution?
  - Explain the vanilla Convolution algorithm.
  - Specify the capability of our implementation
    - Timing analysis (How long does it take?)
    - How much hardware resource do we require?
    - What are the parameters that we allow to take in?
    - 
- Explain the algorithm: How does our convolution work? 
  - Use space-time tables to show the progression of data within the hardware.
- Describe the architecture
  - Active and Dormant Sections
    - How does the shift register array work?
    - What is every functional unit (MAC) calculating?
  - Where and why is the output located?
- Ways in which we've tested out algorithm
- Next steps