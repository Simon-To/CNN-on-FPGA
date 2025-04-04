#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <bitset>
#include <cstdint>
#include <iomanip>

int main() {
    const std::string filename = "atanh_constants.mem";
    std::ifstream infile(filename);
    if (!infile) {
        std::cerr << "Error: Could not open file " << filename << std::endl;
        return 1;
    }

    int N = 32; // Number of bits for U0.32 fixed-point representation
    const size_t N_const = 32;

    
    // U0.32 format uses 32 fractional bits.
    const int FRACTIONAL_BITS = N;
    std::string line;
    
    while (std::getline(infile, line)) {
        // Skip empty lines.
        if (line.empty())
            continue;
        
        // Convert the hex string to a 32-bit unsigned integer.
        // The hex numbers are assumed to be in the file without a "0x" prefix.
        uint32_t fixedPointValue = 0;
        try {
            fixedPointValue = std::stoul(line, nullptr, 16);
        } catch (const std::exception& e) {
            std::cerr << "Error parsing line: " << line << "\n" << e.what() << std::endl;
            continue;
        }
        
        // Create a bitset of 32 bits representing the fixed-point binary.
        std::bitset<N_const> binaryFixedPoint(fixedPointValue);
        
        // Convert back to decimal:
        // For U0.32, the decimal value is fixedPointValue / 2^32.
        double decimalValue = static_cast<double>(fixedPointValue) / static_cast<double>(1ULL << FRACTIONAL_BITS);
        
        // Print out the hexadecimal, binary, and decimal values.
        std::cout << "Hex: " << line 
                  << "\nBinary: 0b" << binaryFixedPoint.to_string() 
                  << "\nDecimal: " << std::fixed << std::setprecision(10) << decimalValue 
                  << "\n\n";
    }
    
    return 0;
}
