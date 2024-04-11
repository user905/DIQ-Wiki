# This code generates 3 CSV files and 1 JSON file summarizing the changes between diq_data.json and diq_data_v4.json
# The 3 CSV files are:
# metadata_changes.csv: shows all changes made to DIQ, including DIQ deletions, DIQ renames, and DIQ modifications
# The JSON file is: metadata_changes.json, which is the above in JSON format
# UIDs_in_v4_only.csv: shows all UIDs present in diq_data_v4.json but not in diq_data.json
# new_DIQs.csv: shows all new DIQs by UID & name
# new_DIQs.json: shows all new DIQs by UID & name in JSON format

import json
import pandas as pd
import os

output_dir = "./diff/metadata"

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

with open("diq_data.json") as json_file:
    diq_data = json.load(json_file)
with open("diq_data_v4.json") as json_file_v4:
    diq_data_v4 = json.load(json_file_v4)

changes = []
unique_UID_v4 = []
unique_UID = []

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
            unique_UID_v4.append([value_v4.get('UID'), key_v4])  # Storing UID along with DIQ Name

# Check each object in diq_data against diq_data_v4
for key, value in diq_data.items():
    UID_found = False
    for key_v4, value_v4 in diq_data_v4.items():
        if value.get('UID') == value_v4.get('UID'):
            UID_found = True
    # If UID not found in diq_data_v4
    if not UID_found:
        unique_UID.append([value.get('UID'), key])  # Storing UID along with DIQ Name

# Convert the changes into a DataFrame for easier CSV export
df_changes = pd.DataFrame(changes, columns=['UID','DIQ Name', 'New DIQ Name', 'Subkey', 'Old Value', 'New Value'])
df_UID_v4 = pd.DataFrame(unique_UID_v4, columns=['UID', 'DIQ Name'])
df_UID = pd.DataFrame(unique_UID, columns=['UID', 'DIQ Name'])

# Export the DataFrames to CSV
df_changes.to_csv(os.path.join(output_dir,'metadata_changes.csv'), index=False)
df_UID_v4.to_csv(os.path.join(output_dir,'UIDs_in_v4_only.csv'), index=False)
df_UID.to_csv(os.path.join(output_dir,'new_DIQs.csv'), index=False)

# Convert DataFrame to json (records format creates a list of dict) and save as .json file
df_changes.to_json(os.path.join(output_dir,'metadata_changes.json'), orient='records')
df_UID.to_json(os.path.join(output_dir,'new_DIQs.json'), orient='records')