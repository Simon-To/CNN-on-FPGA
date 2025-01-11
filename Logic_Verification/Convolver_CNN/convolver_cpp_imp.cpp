#include <iostream>
#include <vector>
#include <iomanip> // for std::setw

#include <opencv2/opencv.hpp>


// A helper function to pretty-print 2D vectors
void print2DVector(const std::vector<std::vector<float>>& matrix, const std::string& name) {
    std::cout << name << ":\n";
    for (const auto& row : matrix) {
        for (auto val : row) {
            std::cout << std::setw(6) << val << " ";
        }
        std::cout << "\n";
    }
    std::cout << std::endl;
}

// Convolution function
//  - input: 2D input data (e.g., an image)
//  - kernel: 2D filter (e.g., a 3x3 or 5x5 filter)
//  - stride: step size for moving the kernel
//  - padding: how many 0-value borders to pad around the input
std::vector<std::vector<float>> convolve2D(const std::vector<std::vector<float>>& input,
                                           const std::vector<std::vector<float>>& kernel,
                                           int stride = 1, 
                                           int padding = 0)
{
    // Dimensions for input
    int inHeight = input.size();
    int inWidth  = (inHeight > 0) ? input[0].size() : 0;

    // Dimensions for kernel
    int kHeight = kernel.size();
    int kWidth  = (kHeight > 0) ? kernel[0].size() : 0;
    
    // Calculate the size of the output
    // Output width = ( (InputWidth + 2*padding - KWidth)  / stride ) + 1
    // Output height = ( (InputHeight + 2*padding - KHeight) / stride ) + 1
    int outHeight = (inHeight + 2 * padding - kHeight) / stride + 1;
    int outWidth  = (inWidth  + 2 * padding - kWidth)  / stride + 1;

    // Prepare the output with zeros
    std::vector<std::vector<float>> output(outHeight, std::vector<float>(outWidth, 0.0f));

    // Iterate over every position where the kernel can be placed
    for (int outY = 0; outY < outHeight; ++outY) {
        for (int outX = 0; outX < outWidth; ++outX) {

            float sum = 0.0f;  // Accumulate the result of elementwise multiplication
            
            // (startY, startX) is where the top-left corner of the kernel lands in the input
            int startY = outY * stride - padding;
            int startX = outX * stride - padding;

            // Convolve with the kernel
            for (int kY = 0; kY < kHeight; ++kY) {
                for (int kX = 0; kX < kWidth; ++kX) {
                    // Compute the corresponding input coordinates
                    int inY = startY + kY;
                    int inX = startX + kX;

                    // Check for valid input region (accounting for padding)
                    if (inY >= 0 && inY < inHeight && inX >= 0 && inX < inWidth) {
                        sum += input[inY][inX] * kernel[kY][kX];
                    }
                }
            }
            
            // Assign the sum to the output cell
            output[outY][outX] = sum;
        }
    }

    return output;
}


int main() {
    /* Example usage of the self-implemented convolution function
    // Example input (5x5). Think of it as a single-channel image.
    // Values can be arbitrary; here we use a simple gradient for clarity.
    std::vector<std::vector<float>> inputImage = {
        {1,  2,  3,  4,  5},
        {6,  7,  8,  9,  10},
        {11, 12, 13, 14, 15},
        {16, 17, 18, 19, 20},
        {21, 22, 23, 24, 25}
    };

    // Example kernel (3x3). A simple edge-detect-like kernel or blur kernel, etc.
    // For example, let's try a simple kernel that enhances center pixel.
    // If you want a Sobel-like kernel, you can insert those values here.
    std::vector<std::vector<float>> kernel = {
        { 0, -1,  0},
        {-1,  5, -1},
        { 0, -1,  0}
    };

    // Print the input image
    print2DVector(inputImage, "Input Image");

    // Print the kernel
    print2DVector(kernel, "Kernel");

    // Perform convolution
    // Try different stride/padding values (e.g., stride=1, padding=0).
    // For demonstration, let's keep stride=1 and padding=0.
    std::vector<std::vector<float>> outputFeatureMap = convolve2D(inputImage, kernel, 1, 0);

    // Print the output feature map
    print2DVector(outputFeatureMap, "Output Feature Map");

    return 0;
    */

   // Create an example image (CV_32F for float convolution)
    cv::Mat input = (cv::Mat_<float>(5,5) <<
        1,  2,  3,  4,  5,
        6,  7,  8,  9,  10,
        11, 12, 13, 14, 15,
        16, 17, 18, 19, 20,
        21, 22, 23, 24, 25);

    

    // Define a kernel (3x3)
    cv::Mat kernel = (cv::Mat_<float>(3,3) <<
        0, -1,  0,
       -1,  5, -1,
        0, -1,  0);

    // Output matrix
    cv::Mat output;

    // Convolve
    cv::filter2D(input, output, -1, kernel);

    std::cout << "Output:\n" << output << std::endl;
    return 0;
}
