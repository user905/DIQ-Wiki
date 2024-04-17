import json

# Open and load the JSON files
with open('./diff/metadata/consolidated_metadata_changes.json', 'r') as file:
    metadata_changes = json.load(file)

with open('./diff/sql/sql_changes_summary.json', 'r') as file:
    sql_changes = json.load(file)


def add_or_create_entry(entry):
    # Find if there's a matching entry in metadata_changes
    for change in metadata_changes:
        if change['UID'] == entry['UID']:
            # If found, add the summary to its changes array
            change.setdefault('changes', []).append({
                'Subkey': 'sql',
                'Old Value': '',
                'New Value': entry['Summary']
            })
            return

    # If no match was found, create a new object and add it to metadata_changes
    metadata_changes.append({
        'UID': entry['UID'],
        'DIQ Name': entry.get('Original DIQ Name',''),
        'New DIQ Name': '',
        'changes': [
            {
                'Subkey': 'sql',
                'Old Value': '',
                'New Value': entry['Summary']
            }
        ]
    })


# Process each entry in sql_changes
for entry in sql_changes:
    add_or_create_entry(entry)


# Write the consolidated data back into a new JSON file
with open('./diff/consolidated/diq_changes_consolidated.json', 'w') as file:
    json.dump(metadata_changes, file)
