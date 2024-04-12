import json
from openai import OpenAI
import os
from dotenv import load_dotenv

load_dotenv()
api_key = os.getenv("OPENAI_API_KEY")
client = OpenAI(api_key=api_key)

def query_gpt(messages):
    content = client.chat.completions.create(
        model="gpt-4-0125-preview",
        messages=messages,
        temperature=0
    )
    return content.choices[0].message.content.strip()

# Specify the directory you are reading from and writing to
input_dir = "./diff/sql"
output_dir = "./diff/sql"

changes_summary = []

# Read changes from changes.json
with open(os.path.join(input_dir,'sql_changes.json'), 'r') as json_file:  
    changes = json.load(json_file)

# Iterate through each change
for change in changes:
    # Prepare prompt for OpenAI API
    prompt = [
        {
            "role": "system",
            "content": """You are an assistant that is helping summarize code changes. Be concise. 
            Some guidelines to follow: 
            1. If the logic of a function changed, start with a one to two sentence summary of the change. 
            If several unrelated changes occurred, provide a sentence summary of each, separated by newlines.
            The one exception is if you find a comment to the effect that the function has been replaced. If this is the case, ignore any logic changes and state simply that "DIQ replaced with [replacement function name(s), which are typically provided]".
            2. Use layman's terminology, do not reference code functions, and make reference to what the code did previously, using format "Logic adjusted to do x, rather than y." If there was no change in logic, say "Logic unchanged."
            If subproject_ID was added, state simply that "Logic adjusted to account for addition of subproject_id field."
            If is_indirect was added, state simply that "Logic adjusted to account for addition of is_indirect field."
            3. Do not refer to changes in return type. That will never change.
            4. Do not refer to things that did not change.
            5. Ignore changes to comments, with the exception of the "replaced" rule in #1.
            6. Stay factual. Do not make things up. This goes for acronyms, abbreviations, etc. 
            7. Do not comment on perceived name changes.
            8. Refer to columns by their name. Do not make up names. Same goes for tables. Do not use table aliases.
            8. Again, be concise.

            Here are good examples:
            1. Logic adjusted to consider a period date within 4-6 months from the current project status date, rather than a period within 3-6 months of the project status date.
            2. Logic adjusted to include handling for indirect costs by changing how the 'EOC' field is treated, specifically by introducing a condition to label costs as 'Indirect' if they are marked as such, rather than directly using the 'EOC' value. This change addresses the introduction of an 'is_indirect' flag in the data, which was not previously accounted for.\n\nAdditionally, the logic now considers both 'taskID' and 'subprojectID' when joining data from different sources to calculate resource performance, where previously only 'taskID' was used. This adjustment allows for a more precise matching of data across different tables.

            Here are bad examples and why:
            1. "Logic adjusted to include handling of cases where Work Package ID (WPID) and the indirect cost indicator (is_indirect) might be missing or null. Previously, the function did not account for these scenarios, and now it ensures that even if WPID or is_indirect are null, they are considered in the grouping and joining conditions by treating them as empty strings. This change allows for a more comprehensive analysis of cost data by including all relevant records, even those without a specified WPID or indirect cost indicator."
            Why is this bad? WPID is not a field name. indirect cost indicator is not a field name. The field names are WBS_ID_WP and is_indirect and should only be as such. The explanation is also too long and speculative.
            A better response would be: Logic adjusted to account for cases where WBS_ID_WP and is_indirect are missing or null. 
            In this case, we can forgo stating what occurred previously because it is apparent from the first sentence.
            2. "Logic adjusted to include resources where the EOC is not null in addition to the existing conditions."
            Why is this bad? It's overly explanatory.
            A better response would be: Logic adjusted to include resources where the EOC is not null.
            """
        },
        {
            "role": "user",
            "content": f"Please provide a brief summary of the following code changes:\n\n{change['Diff']}"
        }
    ]

    # Call OpenAI API
    response = query_gpt(prompt)

    # Check if response is "Logic unchanged"
    if response != "Logic unchanged":
        
        # Prepare initial type value
        type_value = change.get('Type', 'N/A')  # Use get method to prevent KeyError and default to 'N/A' if 'Type' isn't provided

        # Get DIQ names
        diq_name_v4 = change.get('DIQ Name v4', '')
        diq_name = change.get('DIQ Name', '')

        # Check if DIQ Name is populated and different from DIQ Name v4
        if diq_name and diq_name_v4 and diq_name != diq_name_v4:
            # Prepend text to response
            response = f"Name changed from {diq_name_v4} to {diq_name}.\n{response}"

        print(f"UID: {change['UID']}, Summary: {response}")
        
        # Append response to changes_summary
        changes_summary.append({
            'UID': change['UID'],
            'DIQ Name v4': diq_name_v4,
            'DIQ Name': diq_name,
            'Summary': response,
            'Type': type_value
        })

# Save the changes_summary to changes_summary.json file in output_dir
with open(os.path.join(output_dir,'sql_changes_summary.json'), 'w') as json_file:  
    json.dump(changes_summary, json_file)
