def generate_table(k, n):
    """
    Generates a markdown table with:
      - Columns labeled: W_0, W_1, ..., W_(k-1)
      - Rows labeled: a_0, a_1, ..., a_(n-1)
      - Each cell contains the string: + W_x * a_y
    """
    # 1) Build the header row
    header_cells = [""] + [f"W_{x}" for x in range(k*k)]
    
    # 2) Build the separator row (use "---" for each column)
    separator_cells = ["---"] * (k*k + 1)
    
    # 3) Build each data row
    #    The leftmost cell is a_y, and each of the k columns
    #    in that row has "+ W_x * a_y"
    rows = []
    for y in range(n*n):
        row_cells = [f"$a_{{{y}}}$"] + [f"$ + W_{{{x}}} \\times a_{{{y}}}$" for x in range(k*k)]
        rows.append(row_cells)
    
    # A small helper to convert a list of cells to a Markdown table line
    def to_markdown_line(cells):
        return "| " + " | ".join(cells) + " |"
    
    # 4) Convert everything to Markdown
    lines = [
        to_markdown_line(header_cells),
        to_markdown_line(separator_cells),
    ]
    for row in rows:
        lines.append(to_markdown_line(row))
    
    return "\n".join(lines)

if __name__ == "__main__":
    # For example, let's generate a 4x3 table (N=4 rows, K=3 columns)
    k = 3
    n = 4
    print(generate_table(k, n))
