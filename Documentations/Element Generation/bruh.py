k = 3  # Example kernel size (adjustable)

# Initialize the Markdown table rows
table_rows = []

# Iterate over `y` to generate each row of the table
for y in range(k):
    # Generate the first cell (a_y)
    row_cells = [f"$a_{{{y}}}$"]  # Use double curly braces to ensure proper LaTeX formatting

    # Generate the remaining cells (e.g., + W_x \times a_y)
    row_cells += [f"$+ W_{{{x}}} \\times a_{{{y}}}$" for x in range(k * k)]

    # Join the row's cells with vertical bars (`|`) to make a Markdown row
    table_rows.append("| " + " | ".join(row_cells) + " |")

# Create the header row
header = "| a_y | " + " | ".join([f"W_{x}" for x in range(k * k)]) + " |"

# Create the separator row (for Markdown table formatting)
separator = "| " + " --- |" * (k * k + 1)

# Combine the header, separator, and rows into the final Markdown table
markdown_table = "\n".join([header, separator] + table_rows)

# Print the Markdown table
print(markdown_table)
