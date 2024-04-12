import json
import os

home_dir = "./diff"
output_dir = os.path.join(home_dir, "consolidated")

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# List to hold all data
consolidated_data = []

# Open and parse metadata_changes.json
with open(os.path.join(home_dir,'metadata/metadata_changes.json'), 'r') as f:
    metadata_changes = json.load(f)

# Make a dictionary where the keys are UIDs and the values are corresponding entries
uid_dict = {}
for entry in metadata_changes:
    uid = entry["UID"]  # Get UID
    
    # If this UID has been encountered before, append this entry to its list of changes 
    if uid in uid_dict:
        # Remove redundant fields from 'entry' before appending it to 'changes'
        entry_stripped = {k: v for k, v in entry.items() if k not in {'UID', 'DIQ Name', 'New DIQ Name'}}
        uid_dict[uid]['changes'].append(entry_stripped)
        
        # If 'New DIQ Name' is not blank in 'entry', update 'New DIQ Name' in uid_dict[uid]
        if 'New DIQ Name' in entry and entry['New DIQ Name']:
            uid_dict[uid]['New DIQ Name'] = entry['New DIQ Name']
    else:
        # This UID has not been encountered before, so create a new dictionary for it
        new_entry = {
            'UID': uid, 
            'DIQ Name': entry['DIQ Name'], 
            'New DIQ Name': entry.get('New DIQ Name', ""), 
            'changes': []
        }
        
        # Remove redundant fields from 'entry'
        entry_stripped = {k: v for k, v in entry.items() if k not in {'UID', 'DIQ Name', 'New DIQ Name'}}
        new_entry['changes'].append(entry_stripped)
        
        uid_dict[uid] = new_entry
    
# Convert the dictionary values (which are dictionaries themselves) into a list
consolidated_data.extend(uid_dict.values())

# Open and parse new_DIQs.json
with open(os.path.join(home_dir,'metadata/new_DIQs.json'), 'r') as f:
    new_DIQs = json.load(f)

# Append each entry in new_DIQs to the consolidated_data,
# with change type set to 'New DIQ'
for entry in new_DIQs:
    entry['change_type'] = 'New DIQ'
    consolidated_data.append(entry)

# Save consolidated_data to /consolidated/consolidated_changes.json
with open(os.path.join(output_dir,'consolidated_metadata_changes.json'), 'w') as f:
    json.dump(consolidated_data, f, indent=4)  # Set indent to 4 for pretty printing
