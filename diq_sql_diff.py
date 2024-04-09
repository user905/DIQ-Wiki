import json
import pandas as pd
import os
import re
from xml.etree import ElementTree
from difflib import unified_diff

# Specify the directory you are reading from and writing to
read_dir = './diff/metadata'
output_dir = "./diff/sql"

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Read changes from 'changes.csv'
changes_df = pd.read_csv(os.path.join(read_dir,'changes.csv'))

changes = []

diqs_folder_v4 = './diqs_v4'
diqs_folder = './diqs'

# Function to clean lines
def clean_lines(lines):
    cleaned_lines = []
    start_found = False
    in_comment_block = False
    for line in lines:
        if 'CREATE FUNCTION' in line:
            start_found = True
        # Check if the line starts a comment block
        if '/**' in line:
            in_comment_block = True
        # Check if the line ends a comment block
        if '*/' in line:
            in_comment_block = False
            continue  # Skip this line
        if start_found and not line.lstrip().startswith('--') and not in_comment_block:
            cleaned_line = re.sub(r'\s', '', line)  # Remove all white spaces, newlines, tabs
            cleaned_lines.append(cleaned_line)
    return cleaned_lines


# Function to extract UID from SQL script
def get_uid(file_content):
    try:
        # Extract only the XML that is contained within the <documentation> tag 
        pattern = re.compile(r"<documentation>(.*?)</documentation>", re.DOTALL)
        xml_content = pattern.search(file_content).group(0)

        # Now parse this XML content to get UID
        tree = ElementTree.fromstring(xml_content)
        return tree.find("UID").text if tree.find("UID") is not None else ''
    except Exception as e:
        print(f"Error parsing XML: {e}")
        return ''

# List all sql files in diqs_folder_v4 and diqs_folder
v4_files = [f for f in os.listdir(diqs_folder_v4) if f.endswith('.sql')]
diqs_files = [f for f in os.listdir(diqs_folder) if f.endswith('.sql')]

# Compare SQL scripts where file names match across diqs_folder_v4 and diqs_folder folders
for v4_file in v4_files:
    if v4_file in diqs_files:
        with open(os.path.join(diqs_folder_v4, v4_file), 'r') as file_v4, open(os.path.join(diqs_folder, v4_file), 'r') as file:
            file_content_v4 = file_v4.read()
            uid = get_uid(file_content_v4)
            lines_v4 = clean_lines(file_content_v4.split('\n'))
            
            lines = clean_lines(file.read().split('\n'))
            diff = list(unified_diff(lines, lines_v4))

            if diff: # If there's a difference
                changes.append({
                    'UID': uid,
                    'DIQ Name v4': v4_file.replace('.sql', ''),
                    'Type': 'Name matched',
                    'Diff': diff
                })

# Iterate through each row in changes DataFrame for name changed files
for idx, row in changes_df.iterrows():
    uid = row['UID']
    diq_name = row['DIQ Name']
    diq_name_v4 = row['New DIQ Name']

    sql_file_v4 = f'{diqs_folder_v4}/{diq_name_v4}.sql'
    sql_file = f'{diqs_folder}/{diq_name}.sql'

    if os.path.isfile(sql_file_v4) and os.path.isfile(sql_file): 
        with open(sql_file_v4, 'r') as file_v4, open(sql_file, 'r') as file:
            file_content_v4 = file_v4.read()
            uid = get_uid(file_content_v4)
            lines_v4 = clean_lines(file_content_v4.split('\n'))
            
            lines = clean_lines(file.read().split('\n'))
            diff = list(unified_diff(lines, lines_v4))

            if diff: # If there's a difference
                changes.append({
                    'UID': uid,
                    'New DIQ Name': diq_name,
                    'DIQ Name v4': diq_name_v4,
                    'Type': 'Name changed',
                    'Diff': diff
                })

# Save the changes to changes.json file in output_dir
with open(os.path.join(output_dir,'changes.json'), 'w') as json_file:  
    json.dump(changes, json_file)
