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
output_filename = "sql_changes_summary.json"

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
            - If the logic of a function changed, start with a one to two sentence summary of the change. 
            If several unrelated changes occurred, provide a sentence summary of each, separated by newlines.
            - Use layman's terminology. Specifically, do not reference SQL functions, CTEs, or joins. 
            For concepts like joins, use replacement terms like 'filters' or 'connections', depending on how the join was implemented.
            - Make reference to what the code did previously, using format "Logic adjusted to do x, rather than y." 
            If there was no change in logic, say "Logic unchanged." 
            If subproject_ID was added, state simply that "Logic adjusted to account for addition of subproject_id field."
            If is_indirect was added, state simply that "Logic adjusted to account for addition of is_indirect field. All cases where is_indirect = 'Y' are treated as indirect data." 
            - Do not refer to changes in return type. That will never change.
            - Do not refer to things that did not change.
            - Ignore changes to comments or whitespace.
            - Stay factual. Do not make things up. This goes for acronyms, abbreviations, etc. 
            - Do not comment on perceived name changes.
            - Refer to columns by their name. Do not make up names. Same goes for tables. Do not use table aliases.
            - Again, be concise.
            - Take your time and think step by step.

            Here are good examples:
            1. Logic adjusted to consider a period date within 4-6 months from the current project status date, rather than 3-6 months.
            2. Logic adjusted to handle the addition of 'indirect' to the 'EOC' field, as well as the introduction of the 'is_indirect' field.
            \n\nAdditionally, the logic now considers both 'taskID' and 'subprojectID' to calculate resource performance, where previously only 'taskID' was used.

            Here are bad examples and why:
            1. "Logic adjusted to include handling of cases where Work Package ID (WPID) and the indirect cost indicator (is_indirect) might be missing or null. Previously, the function did not account for these scenarios, and now it ensures that even if WPID or is_indirect are null, they are considered in the grouping and joining conditions by treating them as empty strings. This change allows for a more comprehensive analysis of cost data by including all relevant records, even those without a specified WPID or indirect cost indicator."
            Why is this bad? WPID is not a field name. indirect cost indicator is not a field name. The field names are WBS_ID_WP and is_indirect and should be referenced as such. The explanation is also too long and speculative.
            A better response would be: "Logic adjusted to account for cases where WBS_ID_WP and is_indirect are missing or null."
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

    if 'logic unchanged' in response.lower():
        continue

    # Log response to responses.json
    with open(os.path.join(input_dir,output_filename), 'a+') as f:
        # If it's the first entry, add an array
        if os.stat(f.name).st_size == 0:
            f.write("[\n")
        # If not the first entry, add a comma
        else:
            f.write(",\n")

        f.write(json.dumps({
            'UID': change['UID'],
            'Original DIQ Name': change.get('Original DIQ Name', ''),
            'New DIQ Name': change.get('New DIQ Name', ''),
            'Summary': response,
            'Unchanged?': "Y" if response == "Logic unchanged." else "N"
        }, indent=4))

        print(f"UID: {change['UID']}, Summary: {response}")

        diq_name_new = change.get('New DIQ Name', '')
        diq_name_orig = change.get('Original DIQ Name', '')

        # Check if DIQ Name is populated and different from Original DIQ Name 
        if diq_name_new and diq_name_orig and diq_name_new != diq_name_orig:
            # If so, prepend text to response
            response = f"Name changed from {diq_name_orig} to {diq_name_new}.\n{response}"
        
        # Append response to changes_summary
        changes_summary.append({
            'UID': change['UID'],
            'Original DIQ Name': diq_name_orig,
            'New DIQ Name': diq_name_new,
            'Summary': response
        })

    # Log response to responses.json
    with open(os.path.join(input_dir,output_filename), 'a+') as f:
        f.write("\n")

# Log response to json
with open(os.path.join(input_dir,output_filename), 'r') as f:
    content = f.read()

with open(os.path.join(input_dir,output_filename), 'w') as f:
    f.write(content[:-1])
    f.write("]")
        

# Save the changes_summary to changes_summary.json file
# with open(os.path.join(input_dir,'sql_changes_summary.json'), 'w') as json_file:  
#     json.dump(changes_summary, json_file)
