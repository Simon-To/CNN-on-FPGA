import math


# def highlight_targets(k, n):
#     for x in range(n-k+1):
#         for y in range(n-k+1):

#             if x == y:
#                 print(f"Highlight cell at x={x} and y={y}")

def generate_table(K, N):
    k = K*K
    n = N*N
    header_cells = [""] + [f"$W_{{{x}}}$" for x in range(k)]
    separator_cells = ["---"] * (k+1)

    rows = []
    for y in range(n):
        row_cells = [f"$a_{{{y}}}$"]
        for x in range(k):
            cell_content = ""
            if x == 0:
                cell_content = f"$0 + W_{{{x}}} * a_{{{y}}}$"
            else:
                cell_content = f"$+ W_{{{x}}} * a_{{{y}}}$"
            # Example highlight condition: highlight if x=1 & y=2

            # if x

            cell_content = coloring(x, y, K, N, cell_content)
            row_cells.append(cell_content)
        rows.append(row_cells)

    def to_md_line(cells):
        return "| " + " | ".join(cells) + " |"
    
    lines = [
        to_md_line(header_cells),
        to_md_line(separator_cells),
    ]
    for row in rows:
        lines.append(to_md_line(row))
    
    return "\n".join(lines)

def assign_colors(K,N):
    colors = []
    i_index = 0
    j_index = 0
    target_index = []
    counter = 0
    for i in range((N - K + 1)):
        j_index = 0
        for j in range((N - K + 1)):
            colors.append((math.floor(255 - counter * (255 / ((N - K + 1) * (N - K + 1)))), 255, 0))
            target_index.append((i_index, j_index))
            counter += 1
            j_index += 1
        i_index += 1
    # print(colors)
    # print(target_index)
    output = dict(zip(target_index, colors))
    print(output)
    return output

# NOTE:
# k is in range [0, (K-1)*(K-1)]
# n is in range [0, (N-1)*(N-1)]
def index_translataion(k, n, K, N):
    k_i = k % K
    k_j = k // K

    n_i = n % N
    n_j = n // N
    print((k_i, k_j), (n_i, n_j))
    return ((k_i, k_j), (n_i, n_j))

def coloring(k, n, K, N, cell_content):
    # Who am I?
    kernel_position = index_translataion(k, n, K, N)
    # How can I know which output element I am helping to calculate?
    # 1. From my input matrix position, go back to find the top-left corner of the kernel
    # in the input matrix.
    kernel_coordinate = kernel_position[0]
    input_coordinate = kernel_position[1]

    top_left = (input_coordinate[0] - kernel_coordinate[0], input_coordinate[1] - kernel_coordinate[1])
    
    coloring = assign_colors(K, N)

    generate_lagend(coloring)

    # 2. Check if the kernel top-left corner's input matrix coordinate is in range [0, (N - K)]
    if ((top_left[0] <= (N - K)) and (top_left[0] >= 0) and top_left[1] <= (N - K) and (top_left[1] >= 0)):
        # 4. If yes, use the kernel top-left corner's input matrix coordinate to find the 
        # correct color using the assign_colors function
        color = str(coloring[top_left])
        # print(color)
        style = 'background-color: rgb' + str(color) + '; color: black;'
        cell_content = f"<mark style='{style}'>{cell_content}</mark>"
        return cell_content
    else: # 3. If not, return original cell content
        return cell_content
    # 3. If not, return original cell content

# Find whether the current kernel element belongs to an output calc thread
# If so, which output element is it helping to calculate

def generate_lagend(color_dict):

    # Start the Markdown table header
    md_lines = [
        "| Color | Meaning |",
        "|-------|---------|"
    ]

    # For each meaning, use its color to create a colored square (span)
    for meaning, color in color_dict.items():
        colored_square = (
            f'<span style="display:inline-block;'
            f'width:15px;height:15px;background-color: rgb{color};"></span>'
        )
        # Add a row to the table
        md_lines.append(f"| {colored_square} | {meaning} |")

    # Combine all lines into a single Markdown string
    markdown_table = "\n".join(md_lines)
    print(markdown_table)


if __name__ == "__main__":
    # print(generate_table(k=9, n=16))
    # assign_colors(3, 4)
    K = int(input("Enter K, side length of kernel: "))
    N = int(input("Enter N, side length of input matrix: "))

    # generate_table((K*K), (N*N))
    # assign_colors(K, N)
    # # print(coloring(2, 3, 3, 4, "0 + $W_0 * a_0$"))
    # index_translataion(4, 9, 3, 4)

    print(generate_table(K, N))






# 255, 255, 0
# 0, 255, 0

