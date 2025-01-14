#include <iostream>
#include "convolver.h"

#include <thread>

using namespace std;

int Convolver::MAC(int weight_val, int kernel_val, int running_sum) {
    return weight_val * kernel_val + running_sum;
}

vector<vector<int>> Convolver::convolve() {
    // STEP 1 STARTS HERE: Declaration of output matrix and shift registers(INCORRECT)
    /*
    Note that this rounds down the result of division, which is the desirable behavior because 
    N is the width of the input matrix AFTER adding padding. The total number of outputs per
    row therefore CANNOT exceed this the maximum number of kernel strides WITHIN the input
    matrix.
    */ 
    int output_width = (Convolver::N - Convolver::K + 1)/Convolver::S;
    vector<vector<int>> output(output_width, vector<int>(output_width, 0));

    /*
    The size of the shift register array is identical to the input matrix.

    At each clock cycle, EVERY register will be populated with its corresponding MAC unit.

    The register array is represented by a 2D vector.

    To emulate the sequential nature of the shift registers, we will use the double buffer
    method, which involve using TWO 2D vectors:
    - shift_reg_old: Holding old values, K rows, N columns
    - shift_reg_new: Holding new values, K rows, N columns

    Note: Although there are K rows, N columns, the output will be produced after 
    shift_reg[K-1][K-1], which is to say that element K to (N-1) inclusive
    */

    // shift_reg_old holds previous iteration's values
    vector<vector<int>> shift_reg_old(Convolver::K, vector<int>(Convolver::N, 0));
    // shift_reg_new holds current iteration's values
    vector<vector<int>> shift_reg_new(Convolver::K, vector<int>(Convolver::N, 0));

    // Number of stalling cycles to facilitate going from one row of kernel to the next row.s
    // int stalling_cycles = Convolver::N - Convolver::K;
    // STEP 1 ENDS HERE

    // STEP 2 STARTS HERE: Convolution Operation
    for (size_t i = 0; i < Convolver::N; i++)
    {
        for (size_t j = 0; j < Convolver::N; j++)
        {
            /*
            In each clock cycle (represented by an iteration in this C++
            verification), ONE element of the input matrix is provided.

            Then we compute the product of each of the KxK elements in the
            kernel with that ONE element in the input matrix in parallel.
            (represented by multithreading in this C++ verification)
            */

            // We will create K threads
            vector<vector<thread>> threads;
            threads.reserve(Convolver::K); // Reserve K rows

            // Launch each thread to process one element within the shift register array
            for (size_t k = 0; k < Convolver::K; k++) { // For each row of shift_reg
                threads.emplace_back();
                threads[k].reserve(Convolver::N); // Reserve N elements per row

                for (size_t l = 0;l < Convolver::N; l++) // For each element in the row (column of shift_reg)
                { 
                    threads[k].emplace_back([
                        this, 
                        &shift_reg_old, 
                        &shift_reg_new,
                        &output,
                        i, j, k, l]() {

                        // Step 1: Compute the product of the kernel elements with the input element
                        // This should result in KxK number of products.

                        // /* Step 2: Put them into the right spot in the output matrix.

                        // Now, we already have input[i][j] * kernel[k][l] where k and l go from 0 to 
                        // K-1 respectively.
                        
                        // Where should we put them? More specifically, for each of the product that 
                        // we just computed, which element of the output matrix would require this 
                        // product?
                        // */
                        
                        // ACTIVE SECTION OPERATIONS STARTS HERE
                        if ((k >= 0 && k <= (Convolver::K)) && (l >= 0 && l <= (Convolver::K))) {
                            
                            if (l == 0) 
                            {
                                // At the left-most column of the register array
                                if (k == 0)
                                {
                                    // cout << "We're in spec case 1" << endl;
                                    // Special Case 1: Top Left element of the register array
                                    shift_reg_new[k][l] = Convolver::MAC(kernel[k][l], input[i][j], 0);
                                }
                                else
                                {
                                    // Special Case 3: Non-top Left-most element of the register array
                                    // Access the right-most register in the previous row.
                                    shift_reg_new[k][l] = Convolver::MAC(kernel[k][l], input[i][j], shift_reg_old[k-1][Convolver::N-1]);
                                }
                                
                                
                            }
                            else if ((k == (Convolver::K - 1)) && (l == (Convolver::K - 1)))
                            {
                                // Special Case 2: Bottom Right element of the register array
                                /* In this case we're completing the output element's calculation, 
                                Instead of assigning to shift_reg_new, we assign to output matrix,
                                but WHERE in the output matrix?

                                To answer this question we have to understand that we're now at 
                                the last element of the kernel (bottom right of the kernel). This
                                means we have to determine if this result is a part of the output.

                                So, give 
                                */

                                int final_value = Convolver::MAC(kernel[k][l], input[i][j], shift_reg_old[k][l-1]);
                                shift_reg_new[k][l] = final_value;
                                /*
                                Output location?
                                This is the last element of the kernel.
                                
                                I'm at the l

                                */
                                if ( // Check if the current element is a part of the output
                                    // The top-left of the current kernel is located at a stride
                                    (((i - (Convolver::K - 1)) % Convolver::S) == 0) &&
                                    (((j - (Convolver::K - 1)) % Convolver::S) == 0)
                                )
                                {
                                    int output_row = (i - (Convolver::K - 1))/Convolver::S;
                                    int output_col = (j - (Convolver::K - 1))/Convolver::S;
                                    if (output_row >= 0 && output_col >= 0)
                                    {
                                        output[output_row][output_col] = final_value;
                                        cout << "Looking at input[" << i << "][" << j << "]" << endl;
                                        cout << "Writing to output[" << output_row << "][" << output_col << "]" << endl;
                                        cout << "final_value: " << final_value << endl;
                                    }
                                    
                                    
                                }
                                
                                

                            }
                            else
                            {
                                // Normal Case: Any other element in the register array
                                shift_reg_new[k][l] = Convolver::MAC(kernel[k][l], input[i][j], shift_reg_old[k][l-1]);
                            }
                            
                        }
                        // ACTIVE SECTION OPERATIONS ENDS HERE

                        // DORMANT SECTION OPERATIONS STARTS HERE
                        else
                        {
                            // Shifting towards the right
                            shift_reg_new[k][l] = shift_reg_old[k][l-1];
                        }
                        // DORMANT SECTION OPERATIONS ENDS HERE
                    });
                }
                
            }

            // Join threads to ensure they all finish
            for (auto& row : threads) {
                for (auto& t : row) {
                    // Always good practice to check if the thread is joinable
                    // before joining (though typically it should be).
                    if (t.joinable()) {
                        t.join();
                    }
                }
            }

            // Update shift_reg_old by swapping with shift_reg_new:
            shift_reg_old.swap(shift_reg_new);
            // std::cout << "Updated data:\n";
            // for (auto val : data) {
            //     std::cout << val << " ";
            // }
            // std::cout << std::endl;
            
        }
        
    }

    return output;

    // STEP 2 ENDS HERE: Convolution Operation

    



}