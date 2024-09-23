//
// Created by Simon To on 9/22/24.
//
#include <iostream>
#include <cmath>
//#include "matplotlibcpp.h"

using namespace std;

// Precomputed arctanh values for hyperbolic CORDIC
const int ITERATIONS = 15;
//const double atanhTable[ITERATIONS] = {
//        0.5493061443340548,  // atanh(2^-0)
//        0.25541281188299536, // atanh(2^-1)
//        0.12565721414045302, // atanh(2^-2)
//        0.06258157147700301, // atanh(2^-3)
//        0.031260178490666996, // atanh(2^-4)
//        0.01562627175205226, // atanh(2^-5)
//        0.007812658951540773, // atanh(2^-6)
//        0.003906269868396825, // atanh(2^-7)
//        0.0019531274835325498, // atanh(2^-8)
//        0.0009765628104410351, // atanh(2^-9)
//        0.00048828128880581324, // atanh(2^-10)
//        0.00024414062985063893, // atanh(2^-11)
//        0.00012207031310632979, // atanh(2^-12)
//        0.00006103515631767862, // atanh(2^-13)
//        0.000030517578134473727 // atanh(2^-14)
//};

//for (int i = 0; i < iterations; i++) {
//double value = std::atanh(std::pow(2, -i));
//std::cout << "atanh(2^-" << i << ") = " << value << std::endl;
//}



struct CordicResult {
    double x;
    double y;
    double z;
};

// Function to calculate the hyperbolic CORDIC scaling factor
double calculateHyperbolicScalingFactor() {
    double scalingFactor = 1.0;

//    for (int i = 0; i < ITERATIONS; i++) {
    for (int i = 1; i <= ITERATIONS; i++) {
        scalingFactor *= sqrt(1 - pow(2, -2*i));

//        cout << "scalingFactor[" << (i + 1) << "] = " << scalingFactor << endl;
    }

//    cout << "Scaling Factor An = " << scalingFactor;

    return scalingFactor;
}

double* createAtanhArray(int n) {
    double* atanhArray = new double[n + 1]; // Dynamically allocate an array of size n

    for (int i = 0; i <= n; i++) {
//        atanhArray[i] = std::atanh(std::pow(2, -i)); // Calculate and store atanh(2^-i)
        atanhArray[i] = std::atanh(std::pow(2, -i)); // Calculate and store atanh(2^-i)
//        cout << "atanhArray[" << i << "] = " << atanhArray[i] << endl;
    }



    return atanhArray; // Return the pointer to the array
}

double* createDoubleAtanhArray(int n) {
    double* atanhArray = new double[n + 1]; // Dynamically allocate an array of size n

    for (int i = 0; i <= n; i++) {
//        atanhArray[i] = std::atanh(std::pow(2, -i)); // Calculate and store atanh(2^-i)
        atanhArray[i] = std::atanh(std::pow(2, -i)); // Calculate and store atanh(2^-i)
//        cout << "atanhArray[" << i << "] = " << atanhArray[i] << endl;
    }



    return atanhArray; // Return the pointer to the array
}

// Function to calculate atanh(2^-i) for a given number of iterations
void calculateAtanhValues(int iterations) {
//    std::cout << "atanh(2^-i) values for " << iterations << " iterations:" << std::endl;
    for (int i = 0; i < iterations; i++) {
        double value = std::atanh(std::pow(2, -i));
//        std::cout << "atanh(2^-" << i << ") = " << value << std::endl;
    }
}

// Function that rotate the original angle into the range of [-PI/4, PI/4]   initial value of

CordicResult cordicHyperbolicTanh(double z) {
//    double x = 1.207497067763; // Scaling factor for hyperbolic mode
    double* atanhTable = createAtanhArray(ITERATIONS);

//    double x = calculateHyperbolicScalingFactor();
    double x = 1 / calculateHyperbolicScalingFactor();
    double y = 0.0;
    double angle = z;

//    cout << "Initial x = " << x << endl;
//    cout << "Initial x = " << x << endl;

    for (int i = 1; i < ITERATIONS; i++) {
        double di = (angle < 0) ? -1 : 1;

        // Update x, y, and z
//        double new_x = x - di * y * pow(2, -i);
        double new_x = x + di * y * pow(2, -i);
        double new_y = y + di * x * pow(2, -i);

        angle -= di * atanhTable[i];

        x = new_x;
        y = new_y;
//        cout << "x[" << (i + 1) << "] = " << x << endl;
//        cout << "y[" << (i + 1) << "] = " << y << endl;
    }

    x *= calculateHyperbolicScalingFactor();
    y *= calculateHyperbolicScalingFactor();

    return {x, y, z};
}


CordicResult cordicDoubleHyperbolicTanh(double z) {
//    double x = 1.207497067763; // Scaling factor for hyperbolic mode
    double* atanhTable = createAtanhArray(ITERATIONS);

//    double x = calculateHyperbolicScalingFactor();
    double x = 1 / calculateHyperbolicScalingFactor();
    double y = 0.0;
    double angle = z;

//    cout << "Initial x = " << x << endl;
//    cout << "Initial x = " << x << endl;

    for (int i = 1; i < ITERATIONS; i++) {
        for (int j = 0; j < 2; ++j) {
            double di = (angle < 0) ? -1 : 1;

            // Update x, y, and z
//        double new_x = x - di * y * pow(2, -i);
            double new_x = x + di * y * pow(2, -i);
            double new_y = y + di * x * pow(2, -i);

            angle -= di * atanhTable[i];

            x = new_x;
            y = new_y;
//        cout << "x[" << (i + 1) << "] = " << x << endl;
//        cout << "y[" << (i + 1) << "] = " << y << endl;
        }

    }

//    x *= calculateHyperbolicScalingFactor();
//    y *= calculateHyperbolicScalingFactor();
    x *= pow(calculateHyperbolicScalingFactor(), 2);
    y *= pow(calculateHyperbolicScalingFactor(), 2);

    return {x, y, z};
}


