//
// Created by Simon To on 9/22/24.
//
#include "tanh.h"
#include <iostream>

int main() {
    double z = 0.75; // Example input
    CordicResult result = cordicHyperbolicTanh(z);
//    cout << "sinh(theta) = " << result.y << endl;
//    cout << "cosh(theta) = " << result.x << endl;
//    std::cout << "Tanh(" << z << ") approximated by CORDIC: " << result.y / result.x << std::endl;

//    cout << "sqrt(1 - pow(2, -2*0)) = " << 1.0 * sqrt(1 - pow(2, -2*0)) << endl;


//    for (double test = -20.0; test <= 20.0; test += 0.1) {
//        CordicResult answer = cordicDoubleHyperbolicTanh(test);
//        double cordicValue = answer.y / answer.x;
//        double actualValue = std::tanh(test);
//        double difference = cordicValue - actualValue;
//
//
////        inputs.push_back(test);
////        differences.push_back(difference);
//
//        std::cout << "test = " << test << ", CORDIC = " << cordicValue << ", Actual = " << actualValue << ", Difference = " << difference << std::endl;
//    }

    for (double test = -24; test <= 24; ++test) {
        CordicResult answer = cordicDoubleHyperbolicTanh(-1 * pow(2, test));
        double cordicValue = answer.y / answer.x;
        double actualValue = std::tanh(-1 * pow(2, test));
        double difference = cordicValue - actualValue;


//        inputs.push_back(test);
//        differences.push_back(difference);

        std::cout << "test = " << test << ", CORDIC = " << cordicValue << ", Actual = " << actualValue << ", Difference = " << difference << std::endl;
    }


//    for (double test = -24; test <= 24; ++test) {
//        CordicResult answer = cordicDoubleHyperbolicTanh(pow(2, test));
//        double cordicValue = answer.y / answer.x;
//        double actualValue = std::tanh(pow(2, test));
//        double difference = cordicValue - actualValue;
//
//
////        inputs.push_back(test);
////        differences.push_back(difference);
//
//        std::cout << "test = " << test << ", CORDIC = " << cordicValue << ", Actual = " << actualValue << ", Difference = " << difference << std::endl;
//    }


    return 0;
}