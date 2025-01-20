def generate_table(k, n):
    header_cells = [""] + [f"W_{x}" for x in range(k)]
    separator_cells = ["---"] * (k+1)

    rows = []
    for y in range(n):
        row_cells = [f"a_{y}"]
        for x in range(k):
            cell_content = f"+ $W_{x} * a_{y}$"
            # Example highlight condition: highlight if x=1 & y=2
            if x == 1 and y == 2:
                cell_content = f"<mark>{cell_content}</mark>"
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

if __name__ == "__main__":
    print(generate_table(k=3, n=4))
