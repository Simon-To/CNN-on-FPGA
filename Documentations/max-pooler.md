# Max-Pooler
Document the development of Max Pooling Layer of CNN.

## What is Max-Pooling?

### Why do we need pooling anyway?

From the example that we discussed in [Convolver](./convolver.pdf), we know that if we were given an image matrix of size 5x5, and a kernel of size 3x3, then we will receive a output of size 3x3. If we generalize the side length of the convolver's output matrix, we will express the size of that output matrix as MxM, where M is calculated as follows:

$$
M = \frac{N - K}{S} + 1
$$
where:
- **$M$** is the side length of Convolver's output feature map.  
- **$N$** is the side length of the input image matrix.  
- **$K$** is the side length of the convolutional kernel (filter).  
- **$S$** is the stride size (the step size with which the kernel moves across the input).

For the sake of example, let's say we have a image of size 512x512. Even after Convolution, we still get a feature map of size 510x510. This is quite a large matrix that contains too much information for inference. To expedite the inference process, we should aim to decrease the number of activations passed to the next layer, which would mean less parameters in subsequent layers. Decreasing the size of feature map would also result in a decrease of the amount of memory required throughout the pipeline!

### How do we pool?

The main goal of pooling is to pick the strongest activation within a small region of the feature map such that the network focus its attention on the most salient feature within that region. This allows the network to pick up a more generalized pattern in the input image matrix.

One way of achieving this would be to divide the entire feature map into small grid of size 2x2. Let's say we were given a 7x7 input image matrix, then after convolution, we would have a 5x5 feature map coming out of convolver. As shown below, as the feature map enters the max-pooler, we would divide the feature map into squares of size 2x2 and take the maximum value out of each 2x2 square. The max values will form our output matrix.

(Figure of a 5x5 feature map, divided into 4 smaller grids, each of size 2x2)

This means after receiving a feature map of size MxM, out max-pooler will produce an output matrix of size PxP, where P can be calculated as:
$$
P=\left\lfloor \frac{M}{2} \right\rfloor
$$

### Implementation

#### Input Counter

Remember that our architecture is pipelined, where each element of the input image matrix was given one clock at a time. In addition, from out discussion of [Convolver](./convolver.pdf), we know that not EVERY output from the Convolver should be regarded as valid. Rather, only during a clock in which the result_valid being high should we consider the conv_result as part of the output feature map from Convolution. As a result, we should only the consider input_val (conv_result) when valid_in (result_valid) is high.

To keep track of exactly which element of the feature map we're looking at during any given clock cycle, we require a input_counter that increments whenever a valid input comes in.

Since we are given the size of Input Image Matrix and Kernel at compile time, we can calculate the size of the input and output feature maps of our Max-Pooling Layer at compile time as well. In combination with the input_counter's value, we can ascertain the following information:
- **$x_m$**: The column-index of the input feature map to the pooler.
- **$y_m$**: The row-index of the input feature map to the pooler.
- **$x_p$**: The column-index of the output feature map that the data point is suppose to map to (it would reside in that element of the output matrix if it turns out to be the maximum of the 4 in the 2x2 square).  
- **$y_p$**: The row-index of the output feature map.

#### Max Pool Register Array: Keeping track of the max as inputs come one-by-one

Since out input matrix is given to us element-by-element, a register array is imperative for storing the current max of each 2x2 square. Naturally this register array would have the size of PxP, and we can flatten that 2D array to a P*P-element 1D array. Indexing the this array will simply be: 

$$
\text{max\_pool\_addr} = y_p * P + x_p
$$

#### Skip Counter

Furthermore, we have to deal with scenarios where M, the side length of the input feature map is odd. The reason why this scenario require some extra attention is because we are using 2x2 square for pooling. An odd side length means the entire input matrix cannot be evenly divided by our 2x2 squares.

The convention for dealing with this scenario is simply to ignore the last row and column of the input matrix:
(code:
parameter SKIP_NECESSARY = (M % 2 == 0) ? 1'b0 : 1'b1; // Skip the last row/column if M is odd
)

To facilitate this in our design, we need a skip_counter to remind us to "freeze" our input counter value when an element belonging to the lasts column arrived and should be ignored. Basically, this skip_counter will count to the right-most column index of the input matrix reset itself to 0 in the next clock.

With skip-counter, we determine that we skip an input when: 

$$
\begin{aligned}
(SKIP\_NECESSARY) \;\land\;\bigl(&\;skip\_counter == SKIP\_INDEX \\
&\;\lor\;y_{m} == SKIP\_INDEX\bigr) \\
\longrightarrow\;&\;\text{skip}
\end{aligned}
$$

Where:
(code: 
localparam SKIP_INDEX = M - 1;
)

#### Producing Outputs

There are two types of output that our max-pooler produces:
- output_val (validity indicated by "valid_out"): a single element of the result matrix after max-pooling. This becomes available as soon as the maximum of a 2x2 square is found (ie. when ALL 4 values of a 2x2 pooling window has given to us by input, meaning that the maximum out of the 4 is found).
- output_complete (validity indicated by "end_out"): ALL P*P output matrix is produced within the same clock. This signal only becomes available when ALL inputs are given, meaning that every element in the output matrix is evaluated.

##### Producing output_val

Previously we know that for any given valid input, we already produced the row and column index that the input belongs to in the entire input matrix:
- **$x_m$**: The column-index of the input feature map to the pooler.
- **$y_m$**: The row-index of the input feature map to the pooler.

(left: Figure of a 2x2 grid on a 5x5 feature map, show the x and y indices
right: FIgure of a 2x2 grid on an arbitrary feature map's arbitrary location, show the x and y indices)
Since we know that every input element is given to us in row-major order, and our pooling window is of size 2x2, we can deduce that every input where both $x_m$ and $y_m$ are odd belong to the LAST (bottom-right) element of the 2x2 pooling window. This is shown in the figure above.

With this observation, we can produce the "valid_out_next_clk" signal like below to indicate that a valid element of the output matrix should be produced within this clock cycle.

(code: 
wire valid_out_next_clk = x_m[0] && y_m[0];
)

Now, to produce the correct output_val signal, we simply check if the new input is the new Maximum, if so we provide the input_val straight to output_val, otherwire, we feed the maximum in the register array to the output_val. This is demonstrated in the code below:

(code:
if (valid_out_next_clk) begin
    // This is the last data in this max-pooling window
    valid_out_reg <= 1'b1;
    // Output the max value in this max-pooling window
    output_val_reg <= new_max ? input_val : max_pool[max_pool_addr];
end
)



##### Producing output_complete

output_complete outputs the entire output matrix in one clock cycle. This occurs on the clock after the "end_in" input signal is high. "end_in" is an input signal from prior layers indicating the end of operation. When the max-pooler receives a high "end_in", it knows that the very last element of the input matrix has been conveyed, so the entire output matrix would be available in the max_pool register array at the next posedge of the next clock.

With this knowledge, we assert the "end_out" signal high at the next posedge to inform the next layer in our neural network pipeline that the output_complete is ready.


