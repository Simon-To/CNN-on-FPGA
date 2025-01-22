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

## What is Convolution?

In the Inference stage of Convolutional Neural Network (CNN), convolution operation is done to a given input (an image, for example) for the kernel to produce a feature map.

For the sake of our discussion, let's say there's an input image of size NxN, and we're using a KxK kernel to extract the image's features. Throughout the convolution process, the kernel "slides" across the image with step size of S (where S stands for stride).

Within the area of image where the kernel overlaps, element-wise muiltiplications are performed, and the results of all KxK multiplications are summed together to produce the final result for convolution.

The mathematical expression is detailed below:

$$
S(x, y) = \sum_{m} \sum_{n} I(x + m, y + n) \cdot K(m, n)
$$

Where:
- $S(x, y)$: The value of the resulting **feature map** at position $(x, y)$.
- $I(x, y)$: The input data (e.g., a 2D image or feature map).
- \( K(m, n) \): The filter (or kernel) with dimensions \(M \times N\).
- \( m, n \): Indices of the filter \(K\).
- The operation slides the kernel \(K\) over the input \(I\), performing element-wise multiplication and summing the results for each position.

---

### **Expanded Formula with Stride and Padding**
If you consider stride (\(s\)) and padding (\(p\)), the formula for the output size of the feature map becomes:

$$S(x, y) = \sum_{m=0}^{M-1} \sum_{n=0}^{N-1} I(x \cdot s + m, y \cdot s + n) \cdot K(m, n)$$

And the size of the resulting feature map \( (H_\text{out}, W_\text{out}) \) is:

\[
H_\text{out} = \frac{H_\text{in} - M + 2p}{s} + 1
\]
\[
W_\text{out} = \frac{W_\text{in} - N + 2p}{s} + 1
\]

Where:
- \( H_\text{in}, W_\text{in} \): Height and width of the input.
- \( M, N \): Height and width of the kernel.
- \( s \): Stride.
- \( p \): Padding size.

### Visualize convolution

Let's make life easier by just looking at how the kernel moves in the input image. In this example, our image is of size 5x5, and the kernel has a size of 3x3.

If the stride size (or step size), S, is 1, then the first two steps of the convolution would look something like the following:

| ![S=1 step1](images/N_5_0.png "Image 1") | ![S=1 step2](images/N_5_1.png "Image 2") |
|----------------------------------|----------------------------------|
| Step 1 | Step 2 |

In the figure above, the "a" indicates an element that belongs to the input image, where "w" indicates an element of the kernel. The result of convolution produced in the first step is:

$$S(0, 0) = (w_0*a_0) + (w_1*a_1) + (w_2*a_2) 
            + (w_3*a_4) + (w_4*a_5) + (w_5*a_6)
            + (w_6*a_8) + (w_7*a_9) + (w_8*a_{10})$$

Whereas in the second step, the kernel is shifted by 1 place because the S=1:

$$S(0, 1) = (w_0*a_1) + (w_1*a_2) + (w_2*a_3) 
            + (w_3*a_6) + (w_4*a_7) + (w_5*a_8)
            + (w_6*a_{11}) + (w_7*a_{12}) + (w_8*a_{13})$$

Notice that the image still has one more column on the right where the kernel could move to. This means the output matrix will have 3 elements per row.

By similar logic, we can see that the kernel can move 2 steps down the image, so there are 3 elements per column in the output matrix.

As a result, the resulting output matrix has the size of 3x3.

Let's look at the scenario where the stride size, S, is NOT 1. For example, if S=2, the first two steps would look like below:

| ![S=2 step1](images/N_5_0.png "Image 1") | ![S=2 step2](images/N_5_1_S2.png "Image 2") |
|----------------------------------|----------------------------------|
| Step 1 | Step 2 |

Notice that the second step when S=1 is skipped, and we landed the kernel straight in the right-most position in the input image. This is the direct result of have a stride of 2.

So, each row of the output matrix will only have 2 elements instead of 3. The same goes for the number of rows in total. This means the output matrix will have a size of 2x2.

## How does our implementation work?

Instead of placing the kernel on top of the input matrix and produce the output by summing up the result of multiplication in every cell in the table like how we discussed above, we are going to create the hardware component for each multiplication and summation, and feed each element in the input matrix one buy one.

Firstly, I have to pay tribute to the blog post that inspired this implementation: https://thedatabus.in/convolver

To better explain the algorithm, let's look at a simpler scenario where out input image only has a size of 4x4, and the kernel remain 3x3. As a result, the first of the convolution algorithm will look like below:
![Alt Text](images/N_4.png "Optional Title")

In the explanation of the algorithm, the author included a great visualization of the architecture for the case where N=4, K=3 (The case of our discussion). I've included it below:

![Alt Text](images/convolver.jpg "Optional Title")


Basically, there are as many "muliply and add the result to the running sum" units as the total number of kernels (KxK). We call theses units MAC (Multiply-Accumulate) units.
$a \times b$
In each clock, an element of the input matrix is fed to ALL KxK MACs. In another word, at any given clock cycle, all MACs are provided with the SAME element of the Input matrix.

As a result, for each time step, we're producing the following:

|  | W_0 | W_1 | W_2 | W_3 | W_4 | W_5 | W_6 | W_7 | W_8 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| $a_{0}$ | $ + W_{0} \times a_{0}$ | $ + W_{1} \times a_{0}$ | $ + W_{2} \times a_{0}$ | $ + W_{3} \times a_{0}$ | $ + W_{4} \times a_{0}$ | $ + W_{5} \times a_{0}$ | $ + W_{6} \times a_{0}$ | $ + W_{7} \times a_{0}$ | $ + W_{8} \times a_{0}$ |
| $a_{1}$ | $ + W_{0} \times a_{1}$ | $ + W_{1} \times a_{1}$ | $ + W_{2} \times a_{1}$ | $ + W_{3} \times a_{1}$ | $ + W_{4} \times a_{1}$ | $ + W_{5} \times a_{1}$ | $ + W_{6} \times a_{1}$ | $ + W_{7} \times a_{1}$ | $ + W_{8} \times a_{1}$ |
| $a_{2}$ | $ + W_{0} \times a_{2}$ | $ + W_{1} \times a_{2}$ | $ + W_{2} \times a_{2}$ | $ + W_{3} \times a_{2}$ | $ + W_{4} \times a_{2}$ | $ + W_{5} \times a_{2}$ | $ + W_{6} \times a_{2}$ | $ + W_{7} \times a_{2}$ | $ + W_{8} \times a_{2}$ |
| $a_{3}$ | $ + W_{0} \times a_{3}$ | $ + W_{1} \times a_{3}$ | $ + W_{2} \times a_{3}$ | $ + W_{3} \times a_{3}$ | $ + W_{4} \times a_{3}$ | $ + W_{5} \times a_{3}$ | $ + W_{6} \times a_{3}$ | $ + W_{7} \times a_{3}$ | $ + W_{8} \times a_{3}$ |
| $a_{4}$ | $ + W_{0} \times a_{4}$ | $ + W_{1} \times a_{4}$ | $ + W_{2} \times a_{4}$ | $ + W_{3} \times a_{4}$ | $ + W_{4} \times a_{4}$ | $ + W_{5} \times a_{4}$ | $ + W_{6} \times a_{4}$ | $ + W_{7} \times a_{4}$ | $ + W_{8} \times a_{4}$ |
| $a_{5}$ | $ + W_{0} \times a_{5}$ | $ + W_{1} \times a_{5}$ | $ + W_{2} \times a_{5}$ | $ + W_{3} \times a_{5}$ | $ + W_{4} \times a_{5}$ | $ + W_{5} \times a_{5}$ | $ + W_{6} \times a_{5}$ | $ + W_{7} \times a_{5}$ | $ + W_{8} \times a_{5}$ |
| $a_{6}$ | $ + W_{0} \times a_{6}$ | $ + W_{1} \times a_{6}$ | $ + W_{2} \times a_{6}$ | $ + W_{3} \times a_{6}$ | $ + W_{4} \times a_{6}$ | $ + W_{5} \times a_{6}$ | $ + W_{6} \times a_{6}$ | $ + W_{7} \times a_{6}$ | $ + W_{8} \times a_{6}$ |
| $a_{7}$ | $ + W_{0} \times a_{7}$ | $ + W_{1} \times a_{7}$ | $ + W_{2} \times a_{7}$ | $ + W_{3} \times a_{7}$ | $ + W_{4} \times a_{7}$ | $ + W_{5} \times a_{7}$ | $ + W_{6} \times a_{7}$ | $ + W_{7} \times a_{7}$ | $ + W_{8} \times a_{7}$ |
| $a_{8}$ | $ + W_{0} \times a_{8}$ | $ + W_{1} \times a_{8}$ | $ + W_{2} \times a_{8}$ | $ + W_{3} \times a_{8}$ | $ + W_{4} \times a_{8}$ | $ + W_{5} \times a_{8}$ | $ + W_{6} \times a_{8}$ | $ + W_{7} \times a_{8}$ | $ + W_{8} \times a_{8}$ |
| $a_{9}$ | $ + W_{0} \times a_{9}$ | $ + W_{1} \times a_{9}$ | $ + W_{2} \times a_{9}$ | $ + W_{3} \times a_{9}$ | $ + W_{4} \times a_{9}$ | $ + W_{5} \times a_{9}$ | $ + W_{6} \times a_{9}$ | $ + W_{7} \times a_{9}$ | $ + W_{8} \times a_{9}$ |
| $a_{10}$ | $ + W_{0} \times a_{10}$ | $ + W_{1} \times a_{10}$ | $ + W_{2} \times a_{10}$ | $ + W_{3} \times a_{10}$ | $ + W_{4} \times a_{10}$ | $ + W_{5} \times a_{10}$ | $ + W_{6} \times a_{10}$ | $ + W_{7} \times a_{10}$ | $ + W_{8} \times a_{10}$ |
| $a_{11}$ | $ + W_{0} \times a_{11}$ | $ + W_{1} \times a_{11}$ | $ + W_{2} \times a_{11}$ | $ + W_{3} \times a_{11}$ | $ + W_{4} \times a_{11}$ | $ + W_{5} \times a_{11}$ | $ + W_{6} \times a_{11}$ | $ + W_{7} \times a_{11}$ | $ + W_{8} \times a_{11}$ |
| $a_{12}$ | $ + W_{0} \times a_{12}$ | $ + W_{1} \times a_{12}$ | $ + W_{2} \times a_{12}$ | $ + W_{3} \times a_{12}$ | $ + W_{4} \times a_{12}$ | $ + W_{5} \times a_{12}$ | $ + W_{6} \times a_{12}$ | $ + W_{7} \times a_{12}$ | $ + W_{8} \times a_{12}$ |
| $a_{13}$ | $ + W_{0} \times a_{13}$ | $ + W_{1} \times a_{13}$ | $ + W_{2} \times a_{13}$ | $ + W_{3} \times a_{13}$ | $ + W_{4} \times a_{13}$ | $ + W_{5} \times a_{13}$ | $ + W_{6} \times a_{13}$ | $ + W_{7} \times a_{13}$ | $ + W_{8} \times a_{13}$ |
| $a_{14}$ | $ + W_{0} \times a_{14}$ | $ + W_{1} \times a_{14}$ | $ + W_{2} \times a_{14}$ | $ + W_{3} \times a_{14}$ | $ + W_{4} \times a_{14}$ | $ + W_{5} \times a_{14}$ | $ + W_{6} \times a_{14}$ | $ + W_{7} \times a_{14}$ | $ + W_{8} \times a_{14}$ |
| $a_{15}$ | $ + W_{0} \times a_{15}$ | $ + W_{1} \times a_{15}$ | $ + W_{2} \times a_{15}$ | $ + W_{3} \times a_{15}$ | $ + W_{4} \times a_{15}$ | $ + W_{5} \times a_{15}$ | $ + W_{6} \times a_{15}$ | $ + W_{7} \times a_{15}$ | $ + W_{8} \times a_{15}$ |



|  | W_0 | W_1 | W_2 |
| --- | --- | --- | --- |
| a_0 | + W_0 * a_0 | + W_1 * a_0 | + W_2 * a_0 |
| a_1 | + W_0 * a_1 | + W_1 * a_1 | + W_2 * a_1 |
| a_2 | + W_0 * a_2 | <mark>+ W_1 * a_2</mark> | + W_2 * a_2 |
| a_3 | + W_0 * a_3 | + W_1 * a_3 | + W_2 * a_3 |

|  | W_0 | W_1 | W_2 |
| --- | --- | --- | --- |
| a_0 | + $W_0 * a_0$ | + $W_1 * a_0$ | + $W_2 * a_0$ |
| a_1 | + $W_0 * a_1$ | + $W_1 * a_1$ | + $W_2 * a_1$ |
| a_2 | + $W_0 * a_2$ | <mark>+ $W_1 * a_2$</mark> | + $W_2 * a_2$ |
| a_3 | + $W_0 * a_3$ | + $W_1 * a_3$ | + $W_2 * a_3$ |

expressed as:

𝑆
(
𝑥
,
𝑦
)
=
∑
𝑚
∑
𝑛
𝐼
(
𝑥
+
𝑚
,
𝑦
+
𝑛
)
⋅
𝐾
(
𝑚
,
𝑛
)
S(x,y)= 
m
∑
​
  
n
∑
​
 I(x+m,y+n)⋅K(m,n)