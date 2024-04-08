"""
The following python script reads in a JSON schema file and uses it to generate a structure of markdown pages for a wiki

All files will go in the folder /wikischema

The first file will contain an introduction section populated with the information from the description field of the schema, and then contains a table containing each other property, and its description. The title of the property links to another page.

Each of these su gets a folder and a page called wikischema/[propertyname]/index.md

If the property is simply a simple property like "$schema", the page contains a table with all the details of the property

If it's a complex property such as an array of objects or just an object with sub-properties, it has page with the description and then a table with links to subpages for each property, like wikischema/DS01/WBS_ID/index.md

Here's the start of the schema file, which the code loads from pars-cpp-json-schema-v4-0-0.json in the current directory:

{
  "$id": "https://json.pars.doe.gov/pars-cpp-json-schema-v4-0-0.json",
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "PARS CPP JSON Schema v4-0-0",
  "description": "Placeholder description here",
  "type": "object",
  "properties": {
    "$schema": {
      "type": "string",
      "description": "The JSON schema for this object. This should always be set to the ID of this schema document.",
      "default": "https://json.pars.doe.gov/pars-cpp-json-schema-v4-0-0.json"
    },
    "PARSID": {
      "type": "string",
      "key": true,
      "description": "PARS identifier for the project for which data is submitted. Should look like a 1-4 digit integer, but is a string."
    },
    "CPP_status_date": {
      "type": "string",
      "key": true,
      "description": "Contractor data-as-of-date.",
      "format": "date",
      "examples": ["2020-01-01", "2019-02-026", "2020-10-14"],
      "notes": "CPP-1.CPP_status_date = prior CPP_status_date\nCPP-2.CPP_status_date = prior 2nd CPP_status_date\nCPP-5.CPP_status_date = prior 5th CPP_status_date\nCPP+1.CPP_status_date = next CPP_status_date"
    },
    "DS01": {
      "type": "array",
      "title": "WBS",
      "description": "This data set should be populated with the project's contractor WBS identifiers for the entire span of the project (not the contract).\n Provide the contractor WBS identifiers in a hierarchical structure from the project (not the contract) level to the CA WBS level and to the WP and PP WBS levels. The data set should include all WBS identifiers in all other DSs in the same format.",
      "minItems": 1,
      "items": {
        "type": "object",
        "description": "This object represents a single WBS record for a project",
        "properties": {
          "WBS_ID": {
            "type": "string",
            "key": true,
            "description": "Unique contractor WBS identifier.",
            "minLength": 1,
            "maxLength": 150,
            "examples": ["W001.42.27.02"],
            "$comment": "WBS ID is has a max length of 50 for all new projects. Max length of 150 is enforced here to support specific legacy projects only."
          },
          "title": {
            "type": "string",
            "description": "Unique WBS identifier title.",
            "minLength": 1,
            "maxLength": 255,
            "examples": ["Testing/Surveillance Improvements"]
          },
          "level": {
            "type": "integer",
            "description": "WBS identifier hierarchical level relative to the project.\n The data is > 0, starting with 1 and increments by 1.\n The dataset should have only one level 1 WBS identifier that represents the entire project.",
            "minimum": 1,
            "maximum": 20
          },
          "parent_WBS_ID": {
            "type": "string",
            "description": "WBS identifier of the immediate hierarchical parent.\n Required unless level = 1.",
            "minLength": 1,
            "maxLength": 150,
            "examples": ["1.42.27"],
            "$comment": "WBS ID is has a max length of 50 for all new projects. Max length of 150 is enforced here to support specific legacy projects only."
          },
          "type": {
            "type": "string",
            "description": "WBS type selection: \n • WBS = summary level\n • SLPP = summary level planning package (assigned to project manager not to a CAM; thus, is not a CA and does not have any WP, PP, or lower DS01.WBS_level\n • CA = control account\n • PP = planning package\n • WP = work package\n MR, UB, contingency, and SM tasks should be associated with DS01.type = WBS.\n Should be set to PP or SLPP if DS03.EVT = K.\n BCWS, BCWP, ACWP, and ETC are roll-ups where DS01.type = CA or WBS.\n BCWS, BCWP, ACWP, and ETC are accounted for where DS01.type = WP or PP.\n While not preferred, ACWP may be collected at the CA level, i.e. where DS01.type = CA. However, the level ACWP is collected must be uniform across the dataset, i.e., all at CA or all at WP.",
            "enum": ["WBS", "SLPP", "CA", "PP", "WP"]
          },




"""

import os
import json

# Parse JSON schema file
with open('pars-cpp-json-schema-v4-0-0.json', encoding='utf-8') as json_file:
    data = json.load(json_file)

# Create wiki directory if it does not exist
if not os.path.exists('wikischema'):
    os.makedirs('wikischema')

# Write main page
with open('wikischema/index.md', 'w', encoding='utf-8') as f:
    f.write('# ' + data['title'] + '\n')
    f.write(data['description'] + '\n\n')
    f.write('| Property | Description |\n')
    f.write('| -------- | ----------- |\n')
    for ds in data['properties']:
        f.write(f'| [{ds}](wikischema/{ds}/index.md) | {data["properties"][ds]["description"]} |\n')

# Write property pages
for ds in data['properties']:
    if not os.path.exists(f'wikischema/{ds}'):
        os.makedirs(f'wikischema/{ds}')

    with open(f'wikischema/{ds}/index.md', 'w', encoding='utf-8') as f:
        f.write('# ' + ds + '\n')
        if 'properties' in data['properties'][ds]:
            print(ds)
            f.write(data['properties'][ds]['description'] + '\n\n')
            f.write('| Field | Description |\n')
            f.write('| ------------ | ----------- |\n')
            for field in data['properties'][ds]['properties']:
                f.write(f'| {field} | {data["properties"][ds]["properties"][field]["description"]} |\n')
        if 'items' in data['properties'][ds]:
            print(ds)
            f.write(data['properties'][ds]['description'].replace('\n', '<br/>') + '\n\n') 
            f.write('| ------------ | ----------- |\n')

            for field in data['properties'][ds]['items']['properties']:
                description = data["properties"][ds]["items"]["properties"][field]["description"].replace('\n', '<br/>')
                f.write(f'| {field} | {description} |\n')
                # Create directory for sub-properties
                if not os.path.exists(f'wikischema/{ds}/{field}'):
                    os.makedirs(f'wikischema/{ds}/{field}')

                # Write sub-property pages
                with open(f'wikischema/{ds}/{field}/index.md', 'w', encoding='utf-8') as sub_f:
                    sub_f.write('# ' + field + '\n')
                    sub_f.write('| Detail | Value |\n')
                    sub_f.write('| ------ | ----- |\n')

                    for detail in data['properties'][ds]['items']['properties'][field]:
                        detaildescription = data["properties"][ds]["items"]["properties"][field][detail]
        
                        if(detail == 'enum'):
                            # this means detaildescripton is an array of strings, we should reformat it as bullet points
                            detaildescription = '<br/>'.join(f"* {item}" for item in detaildescription)
                        else:
                            detaildescription = str(detaildescription).replace('\n', '<br/>')

                        sub_f.write(f'| {detail} | {detaildescription} |\n')

        else:
            f.write('| Detail | Value |\n')
            f.write('| ------ | ----- |\n')
            for detail in data['properties'][ds]:
                f.write(f'| {detail} | {data["properties"][ds][detail]} |\n')
