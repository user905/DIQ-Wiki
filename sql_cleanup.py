import os
import re

old_diqs_folder = './diqs_v4'
new_diqs_folder = './diqs'

def remove_empty_lines(directory):
    for filename in os.listdir(directory):
        if filename.endswith(".sql"):  
            with open(os.path.join(directory, filename), 'r') as f:
                lines = f.readlines()

            # Remove empty lines and those just containing spaces/tabs
            cleaned_lines = [l for l in lines if l.strip()]
            
            with open(os.path.join(directory, filename), 'w') as f:
                f.writelines(cleaned_lines)


def remove_sql_comments(directory):
    for filename in os.listdir(directory):
        if filename.endswith(".sql"):  
            with open(os.path.join(directory, filename), 'r') as f:
                lines = f.readlines()
            
            new_lines = []
            in_xml_comment = False
            in_block_comment = False
            
            for line in lines:
                trimmed = line.strip()

                # Identify any xml documentation lines
                if '<documentation>' in line:
                    in_xml_comment = True
                    in_block_comment = False
                if '</documentation>' in line:
                    in_xml_comment = False
                
                # Handle block comments starting or stopping
                if not in_xml_comment:
                    if trimmed.startswith('/*'):
                        in_block_comment = True
                    if trimmed.endswith('*/'):
                        in_block_comment = False
                        continue  # We're skipping the closing line of a block comment
                
                # Skip line if presently in a block comment or it's a single-line comment (starts with --)
                if in_block_comment or (not in_xml_comment and trimmed.startswith('--')):
                    continue
                
                if '<documentation>' in line:
                    new_lines.append('/*\n')

                new_lines.append(line)

                # Append closing XML comment symbol after closing documentation tag
                if '</documentation>' in line:
                    new_lines.append('*/\n')
                    
            with open(os.path.join(directory, filename), 'w') as f:
                f.writelines(new_lines)



remove_sql_comments(old_diqs_folder)
remove_empty_lines(old_diqs_folder)
remove_sql_comments(new_diqs_folder)
remove_empty_lines(new_diqs_folder)