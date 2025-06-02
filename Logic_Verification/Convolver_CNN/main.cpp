#include <iostream>
#include <vector>
#include <thread>
#include "convolver.h"

using namespace std;

int main() {
    /**
     * Inputs
     */

    std::cout << "Hello, World!" << std::endl;

    vector<thread> threads;

    // Convolver convolver = Convolver(5, 3, 1, 5, 5, {{0, -1, 0}, {-1, 5, -1}, {0, -1, 0}}, {{1, 2, 3, 4, 5},
    Convolver convolver(
        4,
        3,
        1,
        5,
        5,
        // { // Kernel Example 1
        //     {0, -1, 0}, 
        //     {-1, 5, -1}, 
        //     {0, -1, 0}
        // },
        // { // Input Example 1
        //     {1, 2, 3, 4, 5},
        //     {6, 7, 8, 9, 10},
        //     {11, 12, 13, 14, 15},
        //     {16, 17, 18, 19, 20},
        //     {21, 22, 23, 24, 25}
        // },
        // { // Kernel Example 2
        //     {-1,  0,  1},
        //     {-2,  0,  2},
        //     {-1,  0,  1}
        // },
        // { // Input Example 2
        //     {  2,  1,  0, -1,  2 },
        //     {  4,  5,  2,  0,  1 },
        //     {  7, 10,  1,  2,  3 },
        //     {  0, -1,  3,  5,  9 },
        //     {  2,  2,  2,  2,  2 }
        // },
        // { // Kernel Example 3
        //     {8,  7,  6},
        //     {5,  4,  3},
        //     {2,  1,  0}
        // },
        // { // Input Example 4
        //     {6, 7, 8, 9, 10},
        //     {16, 17, 18, 19, 20},
        //     {1, 2, 3, 4, 5},
        //     {21, 22, 23, 24, 25},
        //     {11, 12, 13, 14, 15}
        // },
        { // Kernel Example 3
            {0,  1,  2},
            {3,  4,  5},
            {6,  7,  8}
        },
        { // Input Example 3
            {  0,  1,  2,  3},
            {  4,  5,  6,  7},
            {  8,  9, 10, 11},
            { 12, 13, 14, 15}
        },
        false
    );
    
    vector<vector<int>> output = convolver.convolve();

    // Iterate using range-based for loops
    for (const auto& row : output) {           // Loop over each row
        for (const auto& elem : row) {        // Loop over each element in the row
            std::cout << elem << " ";
        }
        std::cout << "\n";  // Newline after each row
        // cout << "Bruh" << endl;
    }






    return 0;
}


