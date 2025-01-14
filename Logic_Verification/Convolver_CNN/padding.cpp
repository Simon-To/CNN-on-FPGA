#include <iostream>
#include <vector>

// Helper to map a padded index x into [0, N-1] by reflection around the borders.
//  - 'pad' is how many rows/cols of padding we add on each side
//  - 'N' is the size of the original matrix dimension
int mirrorIndex(int x, int pad, int N)
{
    // The central (non-padded) region is [pad .. pad+N-1].
    // If x is within that region, map directly to x - pad.
    // Otherwise, reflect about the boundary.

    if (x < pad) {
        // Example: if x=0 and pad=1 => mirror to index pad - x - 1 = 0
        //           if x=0 and pad=2 => mirror to index 1, etc.
        return pad - x - 1;  
    } 
    else if (x >= pad + N) {
        // x is beyond the right/bottom edge.
        // Example: if x=pad+N, that is 1 step beyond the last valid index, so mirror it.
        // Distance from the last central index is: d = x - (pad + N - 1).
        // We then reflect: (N-1) - d
        return (N - 1) - (x - (pad + N - 1));
    } 
    else {
        // x is inside [pad.. pad+N-1], so just offset by 'pad'.
        return x - pad;
    }
}

int main()
{
    // Example: N=5, kernel K=3 => pad = (3-1)/2 = 1
    int N = 5;
    int K = 3;
    int pad = (K - 1) / 2;  // Typical "same" convolution padding

    // Sample 5x5 input
    std::vector<std::vector<int>> input = {
        {1,  2,  3,  4,  5},
        {6,  7,  8,  9,  10},
        {11, 12, 13, 14, 15},
        {16, 17, 18, 19, 20},
        {21, 22, 23, 24, 25}
    };

    // The padded matrix will be (N + 2*pad) x (N + 2*pad)
    int M = N + 2 * pad;
    std::vector<std::vector<int>> padded(M, std::vector<int>(M, 0));

    // Fill the padded matrix by mirroring indexes back into [0..N-1]
    for (int i = 0; i < M; ++i) {
        for (int j = 0; j < M; ++j) {
            int iIn = mirrorIndex(i, pad, N);
            int jIn = mirrorIndex(j, pad, N);
            padded[i][j] = input[iIn][jIn];
        }
    }

    // Print the mirrored (reflected) padded matrix
    std::cout << "Mirrored Padded Matrix (" << M << "x" << M << "):\n";
    for (int i = 0; i < M; ++i) {
        std::cout << "row = " << i << std::endl;
        for (int j = 0; j < M; ++j) {
            std::cout << padded[i][j] << " ";
        }
        std::cout << "\n";
    }

    return 0;
}
