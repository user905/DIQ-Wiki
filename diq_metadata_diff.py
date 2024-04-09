import json
import pandas as pd
import os

# Specify the directory to output files
output_dir = "./diff/metadata"

# Check if the directory exists, if not, create it.
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Load JSON data from both files
with open("diq_data.json") as json_file:
    diq_data = json.load(json_file)
with open("diq_data_v4.json") as json_file_v4:
    diq_data_v4 = json.load(json_file_v4)

# Initialize a lists to hold all changes and unique UIDs
changes = []
unique_UID_v4 = []
unique_UID = []

# Check each object in diq_data_v4 against diq_data
for key_v4, value_v4 in diq_data_v4.items():
    if value_v4.get('status') == 'DELETED':  # Handle DELETED status separately
        value = diq_data.get(key_v4, {})
        if key_v4 not in diq_data:  # if key_v4 is not found in diq_data, we output an NA row
            changes.append(['NA', key_v4, '', 'status', 'NA', value_v4.get('status')])
            continue

        for subkey, subvalue in value_v4.items():
            # If any nested value differs and is not wiki or test
            if subvalue != value.get(subkey) and subkey not in ["wiki", "test"]:
                changes.append([value.get('UID'), key_v4, '', subkey, subvalue, value.get(subkey)])
    else:
        UID_found = False
        for key, value in diq_data.items():
            # If UID matches
            if value_v4.get('UID') == value.get('UID'):
                UID_found = True
                for subkey, subvalue in value_v4.items():
                    # If any nested value differs and is not wiki or test
                    if subvalue != value.get(subkey) and subkey not in ["wiki", "test"]:
                        # Record the change, show old key if it exists, otherwise new key
                        new_key = key if key != key_v4 else ""
                        changes.append(
                            [value.get('UID'), key_v4, new_key, subkey, subvalue, value.get(subkey)])
        # If UID not found in diq_data
        if not UID_found and value_v4.get('UID'):  # Add "and value.get('UID')" to filter out missing UID cases
            unique_UID_v4.append(value_v4.get('UID'))

# Check each object in diq_data against diq_data_v4
for key, value in diq_data.items():
    UID_found = False
    for key_v4, value_v4 in diq_data_v4.items():
        if value.get('UID') == value_v4.get('UID'):
            UID_found = True
    # If UID not found in diq_data_v4
    if not UID_found:
        unique_UID.append(value.get('UID'))

# Convert the changes into a DataFrame for easier CSV export
df_changes = pd.DataFrame(changes, columns=['UID','DIQ Name', 'New DIQ Name', 'Subkey', 'Old Value', 'New Value'])
df_UID_v4 = pd.DataFrame(unique_UID_v4, columns=['Unique UID in diq_data_v4'])
df_UID = pd.DataFrame(unique_UID, columns=['Unique UID in diq_data'])

# Export the DataFrames to CSV
df_changes.to_csv(os.path.join(output_dir,'changes.csv'), index=False)
df_UID_v4.to_csv(os.path.join(output_dir,'UIDs_in_v4_only.csv'), index=False)
df_UID.to_csv(os.path.join(output_dir,'new_UIDs.csv'), index=False)
