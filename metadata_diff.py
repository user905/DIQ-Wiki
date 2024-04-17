# This code generates 3 CSV files and 1 JSON file summarizing the changes between diq_data.json and diq_data_orig.json
# The 3 CSV files are:
# metadata_changes.csv: shows all changes made to DIQ, including DIQ deletions, DIQ renames, and DIQ modifications
# The JSON file is: metadata_changes.json, which is the above in JSON format
# UIDs_in_v4_only.csv: shows all UIDs present in diq_data_orig.json but not in diq_data.json
# new_DIQs.csv: shows all new DIQs by UID & name
# new_DIQs.json: shows all new DIQs by UID & name in JSON format

import json
import pandas as pd
import os

output_dir = "./diff/metadata"

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

with open("diq_data.json") as json_file_new:
    diq_data_new = json.load(json_file_new)
with open("diq_data_v4.json") as json_file_orig:
    diq_data_orig = json.load(json_file_orig)

changes = []
deletions = []  # List to track deletions
unique_UID_orig = []
unique_UID_new = []

for key_orig, value_orig in diq_data_orig.items():
    value_new = diq_data_new.get(key_orig, {})

    # to track when status changes to 'DELETED'
    if 'status' in value_orig and 'status' in value_new:
        if value_orig['status'] != 'DELETED' and value_new['status'] == 'DELETED':
            deletions.append({'UID': value_new.get('UID'), 'DIQ Name': key_orig})

    if value_orig.get('status') == 'DELETED':  # Handle DELETED status separately
        value = diq_data_new.get(key_orig, {})
        if key_orig not in diq_data_new:  # if key_orig is not found in diq_data, we output an NA row
            changes.append(['NA', key_orig, '', 'status', 'NA', value_orig.get('status')])
            continue

        for subkey, subvalue in value_orig.items():
            # If any nested value differs and is not wiki or test
            if subvalue != value.get(subkey) and subkey not in ["wiki", "test"]:
                changes.append([value.get('UID'), key_orig, '', subkey, subvalue, value.get(subkey)])
    else:
        UID_found = False
        for key, value in diq_data_new.items():
            # If UID matches
            if value_orig.get('UID') == value.get('UID'):
                UID_found = True
                for subkey, subvalue in value_orig.items():
                    # If any nested value differs and is not wiki or test
                    if subvalue != value.get(subkey) and subkey not in ["wiki", "test"]:
                        # Record the change, show old key if it exists, otherwise new key
                        new_key = key if key != key_orig else ""
                        changes.append(
                            [value.get('UID'), key_orig, new_key, subkey, subvalue, value.get(subkey)])
        # If UID not found in diq_data
        if not UID_found and value_orig.get('UID'):  # Add "and value.get('UID')" to filter out missing UID cases
            unique_UID_orig.append([value_orig.get('UID'), key_orig])  # Storing UID along with DIQ Name

# Check each object in diq_data_new against diq_data_orig
for key_new, value_new in diq_data_new.items():
    UID_found = False
    for key_orig, value_orig in diq_data_orig.items():
        if value_new.get('UID') == value_orig.get('UID'):
            UID_found = True
            if key_new != key_orig:  # Add this line
                replacement_DIQ = key_new
    # If UID not found in diq_data_orig
    if not UID_found:
        unique_UID_new.append([value_new.get('UID'), key_new])  # Storing UID along with DIQ Name
    elif 'replacement_DIQ' in locals():  # Checks if replacement_DIQ is defined
        # Update the corresponding dictionary in deletions list with Replacement DIQ
        for deletion in deletions:
            if deletion['UID'] == value_new.get('UID'):
                deletion['New DIQ Name'] = replacement_DIQ
        del replacement_DIQ  # Reset the variable for the next iteration

# Convert the changes into a DataFrame for easier CSV export
df_changes = pd.DataFrame(changes, columns=['UID','DIQ Name', 'New DIQ Name', 'Subkey', 'Old Value', 'New Value'])
# df_UID_v4 = pd.DataFrame(unique_UID_orig, columns=['UID', 'DIQ Name'])
df_UID = pd.DataFrame(unique_UID_new, columns=['UID', 'DIQ Name'])

# Export the DataFrames to CSV
df_changes.to_csv(os.path.join(output_dir,'metadata_changes.csv'), index=False)
# df_UID_v4.to_csv(os.path.join(output_dir,'UIDs_in_v4_only.csv'), index=False)
df_UID.to_csv(os.path.join(output_dir,'new_DIQs.csv'), index=False)

# Convert DataFrame to json (records format creates a list of dict) and save as .json file
df_changes.to_json(os.path.join(output_dir,'metadata_changes.json'), orient='records')
df_UID.to_json(os.path.join(output_dir,'new_DIQs.json'), orient='records')

# Write the deletions/replacements list into a JSON file
with open(os.path.join(output_dir,'deletions_and_replacements.json'), 'w') as f:
    json.dump(deletions, f)