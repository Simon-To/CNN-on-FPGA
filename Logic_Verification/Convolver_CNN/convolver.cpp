#include <iostream>
#include "convolver.h"

#include <thread>

using namespace std;

vector<vector<int>> Convolver::convolve() {
    // STEP 1 STARTS HERE: Declaration of output matrix (INCORRECT)
    vector<vector<int>> output(Convolver::N, vector<int>(Convolver::N, 0));

    // STEP 1 ENDS HERE

    // STEP 2 STARTS HERE: Convolution Operation
    for (size_t i = 0; i < Convolver::N; i++)
    {
        for (size_t j = 0; j < Convolver::N; j++)
        {
            // Suppose we have K elements
            // std::vector<int> data = {1, 2, 3, 4, 5};
            // std::size_t thread_num = data.size();

            // We will create K threads
            vector<vector<thread>> threads;
            threads.reserve(Convolver::K); // Reserve K rows

            // Launch each thread to process one element
            for (size_t k = 0; k < Convolver::K; k++) {
                threads.emplace_back();
                threads[k].reserve(Convolver::K); // Reserve K elements per row

                for (size_t l = 0;l < Convolver::K; l++)
                {
                    threads.emplace_back([kernel, i]() {
                        Convolver::output[i][j] = 1;
                        computeOnElement(data[i]);
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

            // Print result
            std::cout << "Updated data:\n";
            for (auto val : data) {
                std::cout << val << " ";
            }
            std::cout << std::endl;
            
        }
        
    }

    // STEP 2 ENDS HERE: Convolution Operation

    



}