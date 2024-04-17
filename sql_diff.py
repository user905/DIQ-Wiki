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
metadata_changes = pd.read_csv(os.path.join(read_dir,'metadata_changes.csv'))

# Load deletions; used to skip diff checks on deleted DIQs
with open(os.path.join(read_dir,'deletions_and_replacements.json'), 'r') as f:
    deletions = json.load(f)

# Create a set of deleted UIDs for faster lookup
deleted_uids = set(deletion['UID'] for deletion in deletions)

changes = []

diqs_folder_orig = './diqs_v4'
diqs_folder_new = './diqs'

# Function to clean lines
def clean_lines(lines):
    cleaned_lines = []
    start_found = False
    for line in lines:
        if 'CREATE FUNCTION' in line:
            start_found = True
        if start_found:
            # Remove leading and trailing whitespace as well as newlines
            cleaned_line = line.strip().rstrip('\n')
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

# List all sql files in diqs_folder_orig and diqs_folder_new
orig_files = [f for f in os.listdir(diqs_folder_orig) if f.endswith('.sql')]
new_files = [f for f in os.listdir(diqs_folder_new) if f.endswith('.sql')]

# Compare SQL scripts where file names match across the /diqs_v4 (old) and /diqs (new)
for orig_file in orig_files:
    if orig_file in new_files:
        with open(os.path.join(diqs_folder_orig, orig_file), 'r') as file_orig, open(os.path.join(diqs_folder_new, orig_file), 'r') as file_new:
            file_content_orig = file_orig.read()
            uid = get_uid(file_content_orig)

            # Skip this file if the DIQ was deleted
            if uid in deleted_uids:
                continue

            lines_orig = clean_lines(file_content_orig.split('\n'))
            lines_new = clean_lines(file_new.read().split('\n'))
            diff = list(unified_diff(lines_orig, lines_new))

            if diff: # If there's a difference
                changes.append({
                    'UID': uid,
                    'Original DIQ Name': orig_file.replace('.sql', ''),
                    'Match Type': 'Name matched',
                    'Diff': diff
                })

seen_combos = set()  # This set stores UIDs that we've already processed
# Compare changes in /diqs and /diqs_v4 where the DIQ name changed but the UID remained the same
for idx, row in metadata_changes.iterrows():
    uid = row['UID']
    diq_name_orig = row['DIQ Name']
    diq_name_new = row['New DIQ Name']

    # If we've already processed this (UID, Original DIQ Name) combination, skip this row
    if (uid, diq_name_orig) in seen_combos:
        continue

    # Otherwise, add to the set
    seen_combos.add((uid, diq_name_orig))

    sql_file_orig = f'{diqs_folder_orig}/{diq_name_orig}.sql'
    sql_file_new = f'{diqs_folder_new}/{diq_name_new}.sql'

    if os.path.isfile(sql_file_orig) and os.path.isfile(sql_file_new): 
        with open(sql_file_orig, 'r') as file_orig, open(sql_file_new, 'r') as file_new:
            file_content_orig = file_orig.read()
            uid = get_uid(file_content_orig)
            lines_orig = clean_lines(file_content_orig.split('\n'))
            lines_new = clean_lines(file_new.read().split('\n'))
            diff = list(unified_diff(lines_orig, lines_new))

            if diff: # If there's a difference
                changes.append({
                    'UID': uid,
                    'Original DIQ Name': diq_name_orig,
                    'New DIQ Name': diq_name_new,
                    'Match Type': 'UID (Name changed)',
                    'Diff': diff
                })

# Save the changes to changes.json file in output_dir
with open(os.path.join(output_dir,'sql_changes.json'), 'w') as json_file:  
    json.dump(changes, json_file)
