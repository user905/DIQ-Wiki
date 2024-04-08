import os

# Set the directory you want to start from
directory = 'tests'
output_file = 'filenames.txt'

# Get the list of filenames in the directory
filenames = [f for f in os.listdir(directory) if os.path.isfile(os.path.join(directory, f))]

# Write the filenames to the output file
with open(output_file, 'w') as outfile:
    for filename in filenames:
        outfile.write(f"{filename}\n")
