import os
import glob
import io

# Directory containing your .md files
directory = './wikijs_published'

# Walk through each .md file in the directory and its subdirectories
for filepath in glob.iglob(directory + '/**/*.md', recursive=True):
    with io.open(filepath, 'r', encoding='utf-8') as file:
        if '> :robot:' in file.read():
            print(f"Deleting file: {filepath}")
            os.remove(filepath)
