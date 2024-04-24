import os
import csv

# Specifying the directory containing sql files
directory = "diqs"

# Creating an empty list to hold the data
data_list = []

# Iterating over each file in the directory
for filename in os.listdir(directory):
    # Checking if file is .sql file
    if filename.endswith(".sql"):
        # Opening the file in 'read' mode
        with open(os.path.join(directory, filename), 'r') as f:
            # Counting the number of lines
            num_lines = sum(1 for line in f)
            
            # Appending the filename and number of lines to the data list
            data_list.append([filename, num_lines])

# Name of the output CSV file
output_file = "file_line_counts.csv"

# Writing the data to a CSV file
with open(output_file, 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    # Writing the header
    writer.writerow(["Filename", "Line_Count"])
    # Writing the data
    writer.writerows(data_list)
