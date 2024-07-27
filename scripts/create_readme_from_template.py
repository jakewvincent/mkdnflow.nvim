# Author: Jake W. Vincent
import csv
import re
import os


# Function to read a csv file
def read_csv(path):
    with open(path) as f:
        reader = csv.DictReader(f)
        data = [row for row in reader]
    return data


# Function to format csv data as a nicely-aligned markdown table
def format_as_md(lst):
    # Get column names
    colnames = list(lst[0])

    # Organize data by column (so it's easy to get the max char width for each column)
    cols = {col: [row[col].replace("\n", "<br>") for row in lst] for col in colnames}
    max_widths = [max([len(cell) for cell in cols[col]] + [len(col)]) for col in cols]
    table = ""  # Initialize the string for the table

    # Add header row first
    for i, name in enumerate(colnames):
        cell = f"| {name} {' ' * (max_widths[i] - len(name))}"
        table += cell
    table += "|\n"

    # Add separator row
    for i in range(len(colnames)):
        table += f"| {'-' * max_widths[i]} "
    table += "|\n"

    # Add cells
    for i, row in enumerate(lst):
        for j, name in enumerate(colnames):
            cell = f"| {cols[name][i]} {' ' * (max_widths[j] - len(cols[name][i]))}"
            table += cell
        table += "|\n"

    # Return the table w/o any adjacent whitespace
    return table.strip()


# Function to replace all the placeholders that have a correspondingly named file in ../data
def replace_placeholders(template):
    # Iterate over matches of the placeholder pattern
    for match in re.findall(r"{{\s*(.*?)\s*}}", template):

        # Replace the placeholder if there's a matching csv file in ../data
        if f"{match}.csv" in files:
            csv_data = read_csv(os.path.join("../data", f"{match}.csv"))
            md_table = format_as_md(csv_data)

            # Perform one replacement
            template = re.sub(rf"{{{{\s*{match}\s*}}}}", md_table, template, 1)

    # The template with all possible substitutions made
    return template


if __name__ == "__main__":
    # Read in the README template
    with open("../README.template.md", "r") as f:
        readme_template = f.read()

    # List the files in the data directory
    files = os.listdir("../data/")

    # Format the README template
    formatted_readme = replace_placeholders(readme_template)

    # Write out the formatted README
    with open("../README.md", "w") as f:
        f.write(formatted_readme)
