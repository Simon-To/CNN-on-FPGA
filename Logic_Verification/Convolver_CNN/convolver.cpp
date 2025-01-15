#include <iostream>
#include "convolver.h"

#include <thread>

using namespace std;

vector<vector<int>> Convolver::input_getter() {
    return Convolver::input;
}

int Convolver::MAC(int weight_val, int kernel_val, int running_sum) {
    return weight_val * kernel_val + running_sum;
}

void Convolver::padding_handler() {
    // Padding length is the base of the division: K/2
    int padding_length = (Convolver::K)/2;

    // int N = static_cast<int>(Convolver::input.size()); 
    // If oldMat is NxN, we assume each row has oldMat[i].size() == N

    // 1) Create new 2D vector of size (N+2B) x (N+2B), defaulted to 0
    std::vector<std::vector<int>> padded_input(Convolver::N + 2*padding_length, std::vector<int>(Convolver::N + 2*padding_length, 0));

    // 2) Copy oldMat into the center of newMat
    //    For each row i in [0..N-1], copy the row into newMat[i+B], starting at column B
    for (int i = 0; i < Convolver::N; ++i) {
        // oldMat[i] is length N
        // newMat[i + B] is length N + 2B
        // Copy oldMat[i] into newMat[i + B], offset by B columns
        std::copy(Convolver::input[i].begin(), Convolver::input[i].end(), padded_input[i + padding_length].begin() + padding_length);
    }

    // Handling mirror padding:
    for (int i = 0; i < (Convolver::N + 2*padding_length); i++)
    {
        for (int j = 0; j < (Convolver::N + 2*padding_length); j++)
        {
            // Zone of Interest: where paddings situated in the new input matrix.

            // Top Left Diagonal Reflection Zone
            if ((i < padding_length) && (j < padding_length))
            {
                // I'm at [0][1], I want to mirror to [3 = (2 - 1) + (2 - 0)][2 = (2 - 1) + (2 - 1)]
                padded_input[i][j] = Convolver::input[padding_length - i][padding_length - j];
                cout << "i: " << i << " j: " << j << " padded_input[i][j]: " << padded_input[i][j] << endl;
            }
            
            // Top Right Diagonal Reflection Zone
            else if ((i < padding_length) && (j >= (Convolver::N + padding_length)))
            {
                // I'm at [0][1], I want to mirror to [3 = (2 - 1) + (2 - 0)][2 = (2 - 1) + (2 - 1)]

                padded_input[i][j] = Convolver::input[padding_length - i][(Convolver::N - 1) - (j - Convolver::N - padding_length) - 1];
                cout << "i: " << i << " j: " << j << " padded_input[i][j]: " << padded_input[i][j] << " = Convolver::input[" << (padding_length - i) << "][" << (Convolver::N - 1) - (j - Convolver::N - padding_length) - 1 << "]" << endl;
            }

            // Bottom Left Diagonal Reflection Zone
            else if ((i >= (Convolver::N + padding_length)) && (j < padding_length))
            {
                padded_input[i][j] = Convolver::input[(Convolver::N - 1) - (i - Convolver::N - padding_length) - 1][padding_length - j];
                cout << "i: " << i << " j: " << j << " padded_input[i][j]: " << padded_input[i][j] << endl;
            }

            // Bottom Right Diagonal Reflection Zone
            else if ((i >= (Convolver::N + padding_length)) && (j >= (Convolver::N + padding_length)))
            {
                padded_input[i][j] = Convolver::input[(Convolver::N - 1) - (i - Convolver::N - padding_length) - 1][(Convolver::N - 1) - (j - Convolver::N - padding_length) - 1];
                cout << "i: " << i << " j: " << j << " padded_input[i][j]: " << padded_input[i][j] << endl;
            }



            // Top Vertical Reflection Zone
            else if ((i < padding_length) && (j >= padding_length) && (j < (Convolver::N + padding_length)))
            {
                padded_input[i][j] = Convolver::input[(padding_length - 1) - i][j - padding_length];
            }

            // Bottom Vertical Reflection Zone
            else if ((i >= (Convolver::N + padding_length)) && (j >= padding_length) && (j < (Convolver::N + padding_length)))
            {
                padded_input[i][j] = Convolver::input[(Convolver::N - 1) - (i - Convolver::N - padding_length)][j - padding_length];
            }



            // Left Horizontal Reflection Zone
            else if ((j < padding_length) && (i >= padding_length) && (i < (Convolver::N + padding_length)))
            {
                padded_input[i][j] = Convolver::input[i - padding_length][(padding_length - 1) - j];
            }

            // Right Horizontal Reflection Zone
            else if ((j >= (Convolver::N + padding_length)) && (i >= padding_length) && (i < (Convolver::N + padding_length)))
            {
                padded_input[i][j] = Convolver::input[i - padding_length][(Convolver::N - 1) - (j - Convolver::N - padding_length)];
            }
            
            // Center Zone
            else
            {
                /* code */
            }
            
        }
        
    }
    

    Convolver::N += 2*padding_length;

    Convolver::input = padded_input;

}


vector<vector<int>> Convolver::convolve() {
    // PADDING STARTS HERE

    // cout << "Before padding: " << endl;

    // for (size_t i = 0; i < Convolver::N; i++)
    // {
    //     for (size_t j = 0; j < Convolver::N; j++)
    //     {
    //         cout << Convolver::input[i][j] << " ";
    //     }
    //     cout << endl;
    // }

    if (Convolver::use_padding)
    {
        Convolver::padding_handler();
    }
    
    

    // cout << "Afters padding: " << endl;

    // for (size_t i = 0; i < Convolver::N; i++)
    // {
    //     for (size_t j = 0; j < Convolver::N; j++)
    //     {
    //         cout << Convolver::input[i][j] << " ";
    //     }
    //     cout << endl;
    // }


    // PADDING ENDS HERE



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