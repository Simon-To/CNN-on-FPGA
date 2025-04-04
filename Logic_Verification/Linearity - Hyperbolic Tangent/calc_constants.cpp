#include <iostream>
#include <fstream>
#include <iomanip>
#include <cmath>
// #include <boost/1.87.0_1/include/boost/dynamic_bitset.hpp>
// #include <include/boost/dynamic_bitset.hpp>
// #include </opt/homebrew/Cellar/boost/1.87.0_1/include/boost/config.hpp>
// #include </opt/homebrew/Cellar/boost/1.87.0_1/include/boost/dynamic_bitset/config.hpp>
// #include </opt/homebrew/Cellar/boost/1.87.0_1/include/boost/dynamic_bitset/dynamic_bitset.hpp>

using namespace std;

int main() {
    // Number of iterations (adjust as needed)
    // int N = 10;
    // For example, we want to repeat iteration 4 for convergence.
    const int repeatIteration = 4;
    
    double scaling_product = 1.0;
    
    // Open output files for writing constants
    std::ofstream atanhFile("atanh_constants.mem");
    std::ofstream scalingFile("scaling_constants.mem");

    // int user_input;
    // cout << "Please enter the total number of iterations (N): " << flush;
    // cin >> user_input;

    // const int N = user_input; // Set N to the user input

    const size_t N_const = 32; // PLEASE CHANGE THIS NUMBER TO MATCH THE NUMBER OF BITS
    int N = 32;

    cout << "Are we using double-iteration to ensure convergence? (1 for yes, 0 for no): " << flush;
    int useDoubleIteration;
    cin >> useDoubleIteration;
    
    if (!atanhFile || !scalingFile) {
        std::cerr << "Error opening output files." << std::endl;
        return 1;
    }

    // Step 1a: Calculate Scaling Factor:
    double scalingFactor = 1.0;

    for (int i = 1; i <= N; i++) {
        scalingFactor *= sqrt(1 - pow(2, -2*i));

//        cout << "scalingFactor[" << (i + 1) << "] = " << scalingFactor << endl;
    }

    if (useDoubleIteration) {
        // If using double-iteration, square the scaling factor
        scalingFactor *= scalingFactor;
    }

    // Step 1b: Write the scaling factor to the file as a 4-digit hexadecimal number

    // Convert scaling product to Q0.N fixed-point: multiply by 2^N.
    uint32_t fixed_scaling = static_cast<uint32_t>(std::round(scalingFactor * (1ULL << (N))));
    // int fixed_scaling = static_cast<int>(std::round(scalingFactor * (1 << 14))) & 0xFFFF;
    // int fixed_atanh = static_cast<int>(std::round(atanh_val * (1 << (N)))) & ((1ULL << (N + 1)) - 1);
    // Write to file as a 4-digit hexadecimal number.
    double decimalScaling = fixed_scaling / static_cast<double>(1ULL << (N));
    cout << "Scaling factor (before fixed-point conversion): " << scalingFactor << std::endl;
    cout << "Scaling factor (Q0.N fixed-point): " << fixed_scaling << std::endl;
    cout << "Decimal value of scaling factor: " << decimalScaling << std::endl;
    // scalingFile << std::uppercase << std::hex 
    // << std::setw(4) << std::setfill('0') 
    // << fixed_scaling << std::endl;

    scalingFile << std::uppercase << std::hex 
                  << std::setw(ceil(N/4)) 
                  << std::setfill('0') 
                  << fixed_scaling << std::endl;

    // Step 2: Calculate and write atanh(2^(-i)) for i = 1 to N
    
    // Iterate from 1 to N to compute each constant
    for (int i = 1; i <= N; i++) {
        // Calculate atanh(2^(-i))
        double atanh_val = std::atanh(std::pow(2.0, -i));
        // Convert to Q1.15 fixed-point: multiply by 2^15 and round.
        
        // cout << "((1ULL << N) - 1) == " << ((1ULL << N) - 1) << endl;

        // uint32_t fixedPoint = static_cast<uint32_t>(std::round(atanh_val * (1ULL << (N - 1)))); // USING U0.32 FIXED POINT FORMAT
        uint32_t fixedPoint = static_cast<uint32_t>(std::round(atanh_val * (1ULL << (N))));

        /*
        cout << "atanh(2^-" << i << ") = " << atanh_val << endl;
        std::cout << "Fixed-point representation (unsigned integer): " << fixedPoint << std::endl;
        std::bitset<static_cast<size_t>(N_const)> binaryFixedPoint(fixedPoint);
        std::cout << "Binary (32-bit): 0b" << binaryFixedPoint << std::endl;
        std::cout << "Decimal value: " << decimalValue << std::endl;
            */
        // double decimalValue = fixedPoint / static_cast<double>(1ULL << (N - 1));
        double decimalValue = fixedPoint / static_cast<double>(1ULL << (N));

        // std::cout << "Fixed-point value (hex): 0x" 
                // << std::hex << fixedPoint << std::dec << std::endl;
        
        cout << "" << endl;



        // int fixed_atanh = static_cast<int>(std::round(atanh_val * (1 << (N - 1)))) & ((1ULL << N) - 1);
        int fixed_atanh = static_cast<int>(std::round(atanh_val * (1 << (N)))) & ((1ULL << (N + 1)) - 1);
        // int fixed_atanh = static_cast<int>(std::round(atanh_val * (1 << (N - 1)))) & 0xFFFF;
        // Write as a 4-digit hexadecimal number to file.
        atanhFile << std::uppercase << std::hex 
                  << std::setw(ceil(N/4)) 
                  << std::setfill('0') 
                  << fixedPoint << std::endl;
                  
        // Calculate the scaling factor for this iteration:
        // Each iteration contributes a factor: 1/sqrt(1 - 2^(-2*i))
        // double factor = 1.0 / std::sqrt(1 - std::pow(2.0, -2 * i));
        
        // If this iteration is the one repeated, multiply the factor twice.
        // if(i == repeatIteration) {
        //     scaling_product *= (factor * factor);
        // } else {
        //     scaling_product *= factor;
        // }
        
        // Convert scaling product to Q2.14 fixed-point: multiply by 2^14.
        // int fixed_scaling = static_cast<int>(std::round(scaling_product * (1 << 14))) & 0xFFFF;
        // // Write to file as a 4-digit hexadecimal number.
        // scalingFile << std::uppercase << std::hex 
        //             << std::setw(4) << std::setfill('0') 
        //             << fixed_scaling << std::endl;
    }
    
    atanhFile.close();
    scalingFile.close();
    
    std::cout << "Constants generated successfully." << std::endl;
    return 0;
}
