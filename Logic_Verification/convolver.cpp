#include <iostream>
#include <string>
#include <vector>

using namespace std;

class MyClass {
private:
    // Private member variables (attributes)
    vector<vector<int>> kernel;     // Kernel of convolution
    vector<vector<int>> input;      // Input matrix to perform convolution
    int stride_size;                // Stride size for convolution
    int attribute1;
    double attribute2;
    std::string attribute3;

public:
    // Constructor
    MyClass(const vector<vector<int>>& kernel, const vector<vector<int>>& input, int stride_size, int a1, double a2, const std::string& a3)
        : kernel(kernel), input(input), stride_size(stride_size), attribute1(a1), attribute2(a2), attribute3(a3) {}

    // Default constructor
    MyClass() : kernel(vector<vector<int>>(1, vector<int>(1, 0))), attribute1(0), attribute2(0.0), attribute3("default") {}

    // Destructor
    ~MyClass() {}

    // Public member functions (methods)

    // Setter for attribute1
    void setAttribute1(int value) {
        attribute1 = value;
    }

    // Getter for attribute1
    int getAttribute1() const {
        return attribute1;
    }

    // Setter for attribute2
    void setAttribute2(double value) {
        attribute2 = value;
    }

    // Getter for attribute2
    double getAttribute2() const {
        return attribute2;
    }

    // Setter for attribute3
    void setAttribute3(const std::string& value) {
        attribute3 = value;
    }

    // Getter for attribute3
    std::string getAttribute3() const {
        return attribute3;
    }

    // Example of a public method that does something with the attributes
    void printAttributes() const {
        std::cout << "Attribute 1: " << attribute1 << std::endl;
        std::cout << "Attribute 2: " << attribute2 << std::endl;
        std::cout << "Attribute 3: " << attribute3 << std::endl;
    }
};

int main() {
    // // Create an object of MyClass
    // MyClass myObject(10, 20.5, "Hello");

    // // Access and modify attributes using setter and getter methods
    // myObject.setAttribute1(15);
    // std::cout << "Updated Attribute 1: " << myObject.getAttribute1() << std::endl;

    // // Print all attributes
    // myObject.printAttributes();
    std::cout << "BRooodfsd" << std::endl;

    return 0;
}
