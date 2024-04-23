import os

def write_sections_to_index(files, root_dir):
    for filename in files:
        filepath = os.path.join(root_dir, filename) # Getting complete path
        with open(filepath, 'r') as md_file:
            lines = md_file.readlines()

        # The name of the section to be used as a heading in the index.md files (e.g., ERROR, WARNING, ALERT)
        section_name = filename.split('.')[0].upper()
        ds_number = None
        section_lines = []

        for line in lines:
            if line.startswith('## '):  # Section header found
                if ds_number is not None and section_lines:  # If there's a previous section captured
                    write_section_to_index(ds_number, section_name, section_lines, root_dir)
                
                # Extract the new DS number and reset the section lines
                ds_number = line.split(' ')[1].strip()
                section_lines = []
            else:
                section_lines.append(line)

        # Write the last section to the corresponding index.md file
        if ds_number is not None and section_lines:
            write_section_to_index(ds_number, section_name, section_lines, root_dir)


def write_section_to_index(ds_number, section_name, section_lines, root_dir):
    ds_dir = os.path.join(root_dir, ds_number)
    if os.path.isdir(ds_dir):  # Ensure the directory exists
        index_file = os.path.join(ds_dir, 'index.md')

        with open(index_file, 'a') as f:  # Open the file in append mode
            f.write(f'## {section_name}\n')
            f.writelines(section_lines)  # Write the section lines


md_files = ['Error.md', 'Warning.md', 'Alert.md']
root_directory = 'wikijs'

write_sections_to_index(md_files, root_directory)
