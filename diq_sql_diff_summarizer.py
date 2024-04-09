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
with open(os.path.join(input_dir,'changes.json'), 'r') as json_file:  
    changes = json.load(json_file)

# Iterate through each change
for change in changes:
    # Prepare prompt for OpenAI API
    prompt = [
        {
            "role": "system",
            "content": """You are an assistant that is helping summarize code changes. Be concise. 
            Some guidelines to follow: 
            1. If the logic of a function changed, start with a one to two sentence summary of the change. Use layman's terminology, do not reference code functions, and make reference to what the code did previously. Use a format like "The logic was adjusted to do x, rather than y." 
            2. Do not refer to changes in return type. That will never change.
            3. Do not refer to things that did not change.
            4. If there was a name change, simply state: "Function name changed from ... to ...".
            5. Ignore comment changes.
            6. Do not make things up.

            Here is an example:
            The logic was adjusted to consider a period date within 4-6 months from the current project status date, rather than a period within 3-6 months of the project status date.
            Function name changed from fnDIQ_DS03_Cost_DoesPPStartInThreeToSixMonths to fnDIQ_DS03_Cost_DoesPPStartInFourToSixMonths.
            """
        },
        {
            "role": "user",
            "content": f"Please provide a brief summary of the following code changes:\n\n{change['Diff']}"
        }
    ]

    # Call OpenAI API
    response = query_gpt(prompt)

    # Append response to changes_summary
    changes_summary.append({
        'UID': change['UID'],
        'DIQ Name v4': change.get('DIQ Name v4', ''),  # Use get method to prevent KeyError
        'DIQ Name': change.get('DIQ Name', ''),   # Use get method to prevent KeyError
        'Summary': response,
        'Type': change.get('Type', 'N/A')  # Use get method to prevent KeyError and default to 'N/A' if 'Type' isn't provided
    })

# Save the changes_summary to changes_summary.json file in output_dir
with open(os.path.join(output_dir,'changes_summary.json'), 'w') as json_file:  
    json.dump(changes_summary, json_file)
