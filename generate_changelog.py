import json
import os

def write_to_changelog():
    # Construct the filepath for your JSON files
    diq_changes_consolidated_path = "./diff/consolidated/diq_changes_consolidated.json"
    diq_data_path = "./diq_data.json"

    # Ensure that the JSON files exist at the provided path
    if not os.path.exists(diq_changes_consolidated_path) or not os.path.exists(diq_data_path):
        print("One or more required JSON files do not exist.")
        return

    # # Load the JSON data
    with open(diq_changes_consolidated_path) as f:
        consolidated_changes = json.load(f)
        
    with open(diq_data_path) as f:
        diq_data = json.load(f)

    # # Create/open changelog.md in write mode
    with open('./changelog.md', 'w') as file:
        # Write the "Additions" header to the file
        file.write("# Changelog\n")
        file.write("## DID v5 Changes\n")
        file.write("### Additions\n")
        file.write("| UID | Title |\n")
        file.write("| --- | ----- |\n")

        # Iterate through consolidated changes
        for change in consolidated_changes:
            # Check if the change type is "New DIQ", and also making sure it exists in the change dict
            if "change_type" in change and change["change_type"] == "New DIQ":
                # Extract the UID 
                uid = change["UID"]
                
                # Now iterate through diq_data's items
                for _, diq_item in diq_data.items():
                    if diq_item.get('UID') == uid:  # found match by UID
                        title = diq_item.get("title")
                        uid_url = f"[{uid}](/DIQs/DS{uid[1:3]}/{uid})"

                        # Write the record into the markdown table
                        file.write(f"| {uid_url} | {title} |\n")
                        # Print debug information
                        print(f"Wrote: | {uid_url} | {title} |") 
                    
    
    # # Create/open changelog.md in append mode
    with open('./changelog.md', 'a') as file:
        # Write the "Changes" header to the file
        file.write("\n\n### Changes\n")
        file.write("| UID | Title | Changes |\n")
        file.write("| --- | ----- | ------- |\n")

        # Iterate through consolidated changes
        for change in consolidated_changes:
            # Check if the change type is "Changed DIQ", and also making sure it exists in the change dict
            if "changes" in change:
                
                # Extract the UID
                uid = change["UID"]
                
                # Now iterate through diq_data's items
                for _, diq_item in diq_data.items():
                    if diq_item.get('UID') == uid:  # found match by UID
                        title = diq_item.get("title")
                        
                        # Generate URL for the UID
                        uid_url = f"[{uid}](/DIQs/DS{uid[1:3]}/{uid})"
                        
                        # Initialize changes list
                        changes_list = []

                        # Loop through the changes
                        for sub_change in change.get('changes', []):
                            if sub_change.get('Subkey') == 'sql':
                                # Grab the change text and make sure it ends with a period
                                change_text = sub_change.get('New Value')
                                if not change_text.endswith('.'):
                                    change_text += '.'
                                
                                changes_list.append(change_text)

                            else:
                                # For other metadata changes, add only one note
                                if 'Minor changes to metadata.' not in changes_list:
                                    changes_list.append('Minor changes to metadata.')

                        # Join all changes with newline character
                        changes_str = " ".join(changes_list)

                        # Write the record into the markdown table
                        file.write(f"| {uid_url} | {title} | {changes_str} |\n")
                        # Print debug information
                        print(f"Wrote: | {uid_url} | {title} | {changes_str} |") 

    replacements_table = []
    deletions_table = []

    # Open and parse deletions_and_replacements.json
    with open('diff/consolidated/deletions_and_replacements.json', 'r') as f:
        data = json.load(f)

        for item in data:
            unique_name = item.get('DIQ Name')
            uid = item['UID']
            
            # Fetch title from DIQ data
            title = diq_data[unique_name]['title'] if unique_name in diq_data else 'Title not found'

            if 'New DIQ Name' in item:  # This is a replacement
                uid_url = f"[{uid}](/DIQs/DS{uid[1:3]}/{uid})"
                replacements_table.append({'UID': uid_url, 'Title': title})
            else:  # This is a deletion
                deletions_table.append({'UID': uid, 'Title': title})

    # Create markdown tables
    header = "| UID | Title |\n| ---- | ----- |\n"

    # Creating replacements table
    replacements_md = header
    for row in replacements_table:
        replacements_md += f"| {row['UID']} | {row['Title']} |\n"

    # Adding to changelog.md 
    with open('changelog.md', 'a') as f:
        f.write(f"\n### Replacements\n\n{replacements_md}")

    # Creating deletions table
    deletions_md = header
    for row in deletions_table:
        deletions_md += f"| {row['UID']} | {row['Title']} |\n"

    # Adding to changelog.md 
    with open('changelog.md', 'a') as f:
        f.write(f"\n### Deletions\n\n{deletions_md}")



# Call the function
write_to_changelog()
