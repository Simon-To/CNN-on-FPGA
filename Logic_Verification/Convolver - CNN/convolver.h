#include <iostream>
#include <string>
#include <vector>
#include <thread> // For multi-threading

using namespace std;

class Convolver {
private:
    // Private member variables (attributes)
    // Private Part 1: User Input Params:
    int N; // Side length of input matrix
    int K; // Side length of kernel
    int S; // Stride size (horizontal stride = vertical stride)
    int WIDTH; // Width of the bits used
    int Q; // Number of fractional bits in the case of fixed point

    vector<vector<int>> kernel;     // Kernel of convolution
    vector<vector<int>> input;      // Input matrix to perform convolution
    int attribute1;
    double attribute2;
    std::string attribute3;
/**
 * module convolution #( // Declaring convolution as a parameterized module
    // Parameter list BEGINS
    parameter N = 8'h0a,    // Side length of input matrix
    parameter K = 8'h03,    // Side length of kernel
    parameter S = 1,        // Stride size (horizontal stride = vertical stride)
    parameter WIDTH = 16,   // Width of the bits used
    parameter Q = 12        // Number of fractional bits in the case of fixed point
    // Parameter list ENDS
)(
    input clk,              // Clock signal
    input clk_en,           // Clock enables
    input glb_rst,          // Global reset signal
    input [WIDTH-1:0] activation,   // An element in input matrix
    output wire [N-1:0] 
    input wire reset,        // Reset signal
    input wire [3:0] in,     // 4-bit input
    output reg [3:0] out     // 4-bit output
);
 */
public:
    // Main Constructor Implementation:
    Convolver(int N, int K, int S, int WIDTH, int Q, const vector<vector<int>>& kernel, const vector<vector<int>>& input)
        : N(N), K(K), S(S), WIDTH(WIDTH), Q(Q), kernel(kernel), input(input) {
        // Any speConstructor Implementation

    }

    Convolver(const vector<vector<int>>& kernel, const vector<vector<int>>& input, int stride_size, int a1, double a2, const std::string& a3)
        : kernel(kernel), input(input), stride_size(stride_size), attribute1(a1), attribute2(a2), attribute3(a3) {}

    // Default constructor
    Convolver() : kernel(vector<vector<int>>(1, vector<int>(1, 0))), attribute1(0), attribute2(0.0), attribute3("default") {}

    // Destructor
    ~Convolver() {}

    // Public member functions (methods)

    // // Setter for attribute1
    // void setAttribute1(int value) {
    //     attribute1 = value;
    // }

    // // Getter for attribute1
    // int getAttribute1() const {
    //     return attribute1;
    // }


    // Example of a public method that does something with the attributes
    void printAttributes() const {
        std::cout << "Attribute 1: " << attribute1 << std::endl;
        std::cout << "Attribute 2: " << attribute2 << std::endl;
        std::cout << "Attribute 3: " << attribute3 << std::endl;
    }
};

//int main() {
//    // // Create an object of Convolver
//    // Convolver myObject(10, 20.5, "Hello");
//
//    // // Access and modify attributes using setter and getter methods
//    // myObject.setAttribute1(15);
//    // std::cout << "Updated Attribute 1: " << myObject.getAttribute1() << std::endl;
//
//    // // Print all attributes
//    // myObject.printAttributes();
//    std::cout << "BRooodfsd" << std::endl;
//
//    return 0;
//}
