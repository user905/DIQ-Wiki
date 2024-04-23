import json
import os
import re
import openai
import sys
from openai import OpenAI
from collections import defaultdict
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

def create_wiki_page(name, diag):
    print(name, diag)
    print(f"{diag['table']}: {diag['title']}")
    if(diag['status'] == "DELETED"):
        print("Deleted, skipping")
        return
    
    if 'wiki' in diag:
        if(diag['wiki'] == 'generated'):
            print("Already generated, skipping")
            return
        del diag['wiki']
    
    if 'author' in diag:
        del diag['author']

    del diag['param']
    del diag['returns']
    if 'test' in diag:
        del diag['test']

    if int(diag['table'][2:4]) > 22:
        print(diag['table'][2:4])
        return

    print(int(diag['table'][2:4]))
    
    # Open corresponding sql file

    with open(f"diqs/{name}.sql", 'r') as sql_file:
        full_sql_content = [line for line in sql_file if line.strip() != ""]

    full_sql_content = ''.join(full_sql_content)
    # Pattern to remove all content between the first open comment (/*) and the first close comment (*/)
    comment_pattern = r'/\*.*?\*/'
    # Remove all comments from sql_content
    sql_content = re.sub(comment_pattern, '', full_sql_content, flags=re.DOTALL)

    dir_path = f'wikijs/{diag["table"].split(" ")[0]}'

    import copy
    error_data = copy.deepcopy(diag)
    del error_data['severity']
    del error_data['status']

    print(error_data)
    print(diag)

    error_prompt = [
        {
            "role": "system",
            "content": """You are an assistant that is helping define Data Integrity and Quality (DIQ) checks for EVMS construction project management data 
            at the US Department of Energy. You will be provided with information describing properties of a test that is being performed on the data, 
            and code for the actual check that is being performed. Please reply in complete sentences with an explanation that will be provided as part of a user guide 
            to DIQs. Describe briefly what is likely to be causing the error, specifying what fields are causing the issue and what expected values might be. 
            You can refer to the DIQ test, but don't explicitly mention the SQL query. Avoid mentioning the upload_ID field or the fact that the test only runs when needed. 
            Refer to the tables by their DS number and name rather than the exact table name in SQL. Be concise and clear, writing in a professional tone for a user guide."""
                            },
        {
            "role": "user",
            "content": f"DIQ Test information: {error_data} \n\n DIQ Test SQL: {sql_content}"
        }
    ]

    importance_prompt = [
        {
            "role": "system",
            "content": "You are an assistant that is helping define Data Integrity and Quality (DIQ) checks for EVMS construction project management data at the US Department of Energy. You will be provided with information describing properties of a test that is being performed on the data. Please reply in complete sentences with a brief explanation of why this test is being performed, and the importance of this check. Note a severity of ERROR is the worst, meaning this issue must be fixed or the data can't be reviewed, a WARNING is moderate severity implying the issue is likely to cause problems during analysis, while an ALERT is less severe, but indicates there might be minor problems or that the data doesn't follow all best practices."},
        {
            "role": "user",
            "content": f"DIQ Test information: {diag}"
        }
    ]

    """ #skipping for now since the AI isn't great at this

    table_name = diag["table"].split(" ")[0]

    if table_name == "DS01" or table_name == "DS04" or table_name == "DS05" or table_name == "DS06":
        tool = "Oracle P6"
    else:
        tool = "Deltek Cobra"

    fix_prompt = [
        {
            "role": "system",
            "content": f"You are an assistant that is helping define Data Integrity and Quality checks for EVMS construction project management data at the US Department of Energy. You will be provided with a set of data describing properties of a test that is being performed on the data, and code for the actual check that is being performed. The data being checked was exported from {tool}. Please provide a explanation along with step by step instructions on how the contractor might fix the data in {tool} to avoid this issue. Refer the users to the PARS DIQ Reports to identify specific rows that fail the check. You can refer to the DIQ test, but don't explicitly mention the SQL query. Also avoid mentioning the upload_ID field or the fact that the test only runs when needed. Refer to the tables by their DS number and name rather than the exact table name in SQL. Note that {tool} likely doesn't use the exact tables referred to in the DIQ, so use your knowledge of how {tool} works to inform your response."},
        {
            "role": "user",
            "content": f"DIQ Test information: {diag} \n\n DIQ Test SQL: {sql_content}"
        }
    ]

    """

    # Use AI to create explanations
    error_explanation = query_gpt(error_prompt)
    importance_explanation = query_gpt(importance_prompt)
    # fix_explanation = query_gpt(fix_prompt)

    # Check if directory exists, if not, then create it
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)

    with open(f'{dir_path}/{diag["UID"]}.md', 'w') as md_file:
        md_file.write("## Basic Information\n")
        md_file.write("| Key         | Value          |\n")
        md_file.write("|-------------|----------------|\n")
        md_file.write(f"| Table       | {diag['table']} |\n")
        md_file.write(f"| Severity    | {diag['severity']} |\n")
        md_file.write(f"| Unique ID   | {diag['UID']}   |\n")
        md_file.write(f"| Summary     | {diag['summary']} |\n")
        md_file.write(f"| Error message | {diag['message']} |\n")
        
        md_file.write("\n## What causes this error?\n\n")
        md_file.write("> :robot: The following text was generated by an AI tool and hasn't been reviewed for accuracy by a human! It might be useful, but it also might have errors. Are you a human? You can help by reviewing it for accuracy! Edit it as needed then remove this message.\n{.is-warning}\n\n")
        md_file.write(error_explanation)
        
        md_file.write("\n## Why do we check this?\n\n")
        md_file.write("> :robot: The following text was generated by an AI tool and hasn't been reviewed for accuracy by a human! It might be useful, but it also might have errors. Are you a human? You can help by reviewing it for accuracy! Edit it as needed then remove this message.\n{.is-warning}\n\n")
        md_file.write(importance_explanation)
        
    #    md_file.write("\n## How can I fix this in my source data system\n\n")
    #    md_file.write(fix_explanation)
        
        md_file.write("\n## Code\n\n")
        md_file.write("```sql\n")
        md_file.write(sql_content)
        md_file.write("\n```\n")

    #open diq_data.json, find the value with 'name' and add a field called 'wiki' and set it to 'generated', then save the file
    with open('diq_data.json', 'r+') as file:
        diq_data = json.load(file)
        if name in diq_data:   # Check if such a function exists
            diq_data[name]['wiki'] = 'generated'  # Add 'wiki' attribute with value 'generated'
        else:
            print(f"No function named {name} found in the JSON data.")   # Print error message if no such function exists
        file.seek(0)
        json.dump(diq_data, file, indent=4)   # Write the updated data back to file
        file.truncate() 

to_create = {
    "9060304": "fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollarsCA",
    # "9060305": "fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollarsWP",
    # "1030113": "fnDIQ_DS03_Cost_IsODCComingledWithNonIndirectEOCs",
    # "1030117": "fnDIQ_DS03_Cost_IsLaborComingledWithNonIndirectEOCs",
    # "9060306": "fnDIQ_DS06_Res_AreDS03ADollarsMissingResourcePDollarsCA",
    # "9060307": "fnDIQ_DS06_Res_AreDS03LaborAHoursMissingResourceLaborPUnitsCA",
    # "9080411": "fnDIQ_DS08_WAD_AreIndirectDollarsMisalignedWithDS03CA",
    # "1060269": "fnDIQ_DS03_Cost_IsCAWBSEqTWPWBS",
    # "1030111": "fnDIQ_DS03_Cost_IsIndirectBCWSMissingFromProject",
    # "1030094": "fnDIQ_DS03_Cost_IsIndirectInsufficient",
    # "1030095": "fnDIQ_DS03_Cost_IsMatComingledWithNonIndirectEOCs",
    # "1030112": "fnDIQ_DS03_Cost_IsSubKComingledWithNonIndirectEOCs",
    # "1030098": "fnDIQ_DS03_Cost_IsIndirectWorkMissingOtherEOCTypes",
    # "9080433": "fnDIQ_DS08_WAD_IsIndirectBudgetMissingInDS03WP",
    # "9080434": "fnDIQ_DS08_WAD_IsIndirectBudgetMissingInDS03CA",
    # "9080410": "fnDIQ_DS08_WAD_AreIndirectDollarsMisalignedWithDS03WP",
    # "9060302": "fnDIQ_DS06_Res_AreLaborPUnitsMissingDS03LaborAHoursWP",
    # "9060303": "fnDIQ_DS06_Res_AreLaborPUnitsMissingDS03LaborAHoursCA",
    # "1060262": "fnDIQ_DS06_Res_IsIndirectUsedUnevenly",
    # "1060264": "fnDIQ_DS06_Res_AreEOCsComingled",
    # "1060265": "fnDIQ_DS06_Res_IsResourceMissingEOC",
    # "1060266": "fnDIQ_DS06_Res_IsResourceDuplicated",
    # "1060267": "fnDIQ_DS06_Res_DoesIndirectHaveUnits",
    # "1030114": "fnDIQ_DS03_Cost_DoesIndirectHaveHoursOrFTEs",
    # "1030115": "fnDIQ_DS03_Cost_IsIndirectCollectedImproperly",
    # "1030116": "fnDIQ_DS03_Cost_IsIndirectUseInconsistent",
    # "9050283": "fnDIQ_DS05_Logic_IsLOESuccessorRelEqToFF"
}

# Load diq_data.json
with open('diq_data.json') as f:
    data = json.load(f)

count=0
for key, value in enumerate(data.items()):
    # Skip this iteration if value[0] is not in to_create.values()
    if value[0] not in to_create.values():
        continue

    create_wiki_page(value[0], value[1])

# Create default dictionary with list as default value type
ds_tables = defaultdict(list)

# Iterate through all diqs
for key, diag in data.items():
    # Skip this iteration if value[0] is not in to_create.values()
    if key not in to_create.values():
        continue
    # Exclude all rows where status = DELETED
    if diag["status"] != "DELETED":
        # Add each diag to its respective DS' list
        ds_tables[diag["table"].split(" ")[0]].append(diag)

# Iterate through all DS's
for ds, diqs in ds_tables.items():

    # Sort diqs based on Severity and UID 
    diqs.sort(key=lambda x: (x['severity'], x['UID']))
    dir_path = f'wikijs/{ds}'
    
    # Check if directory exists, if not, then create it
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)
    
    with open(f'{dir_path}/index.md', 'w') as ds_index:
        
        for severity in ['ERROR', 'WARNING', 'ALERT']:  
            diqs_severity = [diq for diq in diqs if diq['severity'] == severity]
            if diqs_severity:   # If there are diqs for this severity level
                diqs_severity.sort(key=lambda x: x['UID'])
                
                ds_index.write(f"## [{severity}](/DIQs/{severity.lower()})\n\n")
                ds_index.write("| UID | Title | Summary | Error Message |\n")
                ds_index.write("|-----|-------|---------|---------------|\n")
                        
                for diq in diqs_severity:
                    uid_link = f'[{diq["UID"]}](/DIQs/{ds}/{diq["UID"]})'
                    ds_index.write(f"| {uid_link} | {diq['title']} | {diq['summary']} | {diq['message']} |\n")



severity_order = {'ERROR': 0, 'WARNING': 1, 'ALERT': 2}

with open('wikijs/index.md', 'w') as root_index:
    for ds, diqs in sorted(ds_tables.items()): # Sort by DS 
        ds_link = f"[{ds}](/DIQs/{ds})"
        root_index.write(f"## {ds_link}\n\n")
        root_index.write("| UID | Title | Severity | Summary | Error Message |\n")
        root_index.write("|-----|-------|----------|---------|---------------|\n")
        
        # Sorting diqs by severity then uid
        sorted_diqs = sorted(diqs, key=lambda x: (severity_order[x['severity']], x["UID"]))
        for diq in sorted_diqs:
            uid_link = f'[{diq["UID"]}](/DIQs/{ds}/{diq["UID"]})'
            root_index.write(f"| {uid_link} | {diq['title']} | [{diq['severity']}](/DIQs/{diq['severity'].lower()}) | {diq['summary']} | {diq['message']} |\n")

# Create dictionaries for each severity type
error_diqs = defaultdict(list)
warning_diqs = defaultdict(list)
alert_diqs = defaultdict(list)

# Iterate through all DS's
for ds, diqs in ds_tables.items():
    # Sort diqs based on UID 
    sorted_diqs = sorted(diqs, key=lambda x: x['UID'])

    # Store diqs of each severity in its corresponding list
    for diq in sorted_diqs:
        if diq['severity'] == 'ERROR':
            error_diqs[ds].append(diq)
        elif diq['severity'] == 'WARNING':
            warning_diqs[ds].append(diq)
        elif diq['severity'] == 'ALERT':
            alert_diqs[ds].append(diq)

# Helper function to write data to file
def write_to_file(filename, data):
    with open(f'wikijs/{filename}.md', 'w') as ds_index:
        # sorted() function returns a list of sorted DS numbers
        for ds in sorted(data.keys()):
            diqs = data[ds]

            # Start new section for each DS
            ds_index.write(f"## {ds}\n\n")

            if diqs:   # If there are DIQs for this DS
                ds_index.write("| UID | Title | Summary | Error Message |\n")
                ds_index.write("|-----|-------|---------|---------------|\n")            
                        
                for diq in diqs:
                    uid_link = f'[{diq["UID"]}](/DIQs/{ds}/{diq["UID"]})'
                    ds_index.write(f"| {uid_link} | {diq['title']} | {diq['summary']} | {diq['message']} |\n")

            # Add extra line break after each section
            ds_index.write("\n")


# Write data to each file
write_to_file('error', error_diqs)
write_to_file('warning', warning_diqs)
write_to_file('alert', alert_diqs)

