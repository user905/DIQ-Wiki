import os
import re
import json

# Assuming your key-value pairs are in the following format
# Add all pairs here
uid_file_pairs = {
    '9200596': 'fnDIQ_DS20_Sched_CAL_Excpt_IsCalNameMissingInDS19',
    '1040107': 'fnDIQ_DS04_Sched_Are1xxMSsOutOfOrder',
    '9030072': 'fnDIQ_DS03_Cost_IsWPOrPPMissingInDS04FC',
    '1050234': 'fnDIQ_DS05_Logic_IsSSorFFRelTypeImproperlyLinked',
    '1060261': 'fnDIQ_DS06_Res_IsFCResourceMissingInBL',
    '9030100': 'fnDIQ_DS03_Cost_IsWorkMissingResourcesInDS06',
    '9010015': 'fnDIQ_DS01_WBS_IsWBSMissingInDS04FC',
    '9070369': 'fnDIQ_DS07_IPMR_ArePMBAndMRNotEqToCBB',
    '1060260': 'fnDIQ_DS06_Res_IsBLResourceMissingInFC',
    '9040224': 'fnDIQ_DS04_Sched_IsWBSSummaryResourceLoaded',
    '1060237': 'fnDIQ_DS06_Res_IsBudgetEqToZero',
    '9040214': 'fnDIQ_DS04_Sched_IsSVTOrZBAResourceLoaded',
    '9050282': 'fnDIQ_DS05_Logic_IsTaskMissingInDS04',
    '9010029': 'fnDIQ_DS01_WBS_IsSubprojectIDMissingInDS04',
    '1060247': 'fnDIQ_DS06_Res_IsResourceNameDuplicated',
    '9060284': 'fnDIQ_DS06_Res_ArePDollarsMisalignedWithDS03',
    '9010014': 'fnDIQ_DS01_WBS_IsWBSMissingInDS03CA',
    '1030075': 'fnDIQ_DS03_Cost_Is5050BCWSImproperlySpread',
    '1030088': 'fnDIQ_DS03_Cost_IsLaborMissingACWPDollarsHoursOrFTEs',
    '9040217': 'fnDIQ_DS04_Sched_IsTaskMissingResources',
    '1030081': 'fnDIQ_DS03_Cost_IsBCWSMissing',
    '1020040': 'fnDIQ_DS02_OBS_DoesTitleContainOBSID',
    '9010013': 'fnDIQ_DS01_WBS_IsWBSMissingInDS03WP',
    '9060294': 'fnDIQ_DS06_Res_IsEOCComboMisalignedWithDS03',
    '9050280': 'fnDIQ_DS05_Logic_IsLagMissingJustification',
    '9060298': 'fnDIQ_DS06_Res_AreRemUnitsMisalignedWithDS03BCWRHours',
    '1030091': 'fnDIQ_DS03_Cost_IsLaborMissingETCDollarsHoursOrFTEs',
    '9060293': 'fnDIQ_DS06_Res_IsCalendarMissingInDS19',
    '9060300': 'fnDIQ_DS06_Res_IsStartDateEarlierThanDS04ESDate',
    '9060290': 'fnDIQ_DS06_Res_AreSDollarsMisalignedWithDS03SDollars',
    '9170579': 'fnDIQ_DS17_WBS_EU_IsWBSAndEOCComboNotInDS03',
    '1080404': 'fnDIQ_DS08_WAD_IsBudgetNegativeOrMissing',
    '9050281': 'fnDIQ_DS05_Logic_IsPredMissingInDS04',
    '9030324': 'fnDIQ_DS03_Cost_IsEVTMisalignedWithDS08',
    '9060291': 'fnDIQ_DS06_Res_AreLaborSUnitsMisalignedWithDS03LaborSHours'
    } 

with open('diff/consolidated/diq_changes_consolidated.json', 'r') as f:
    diq_changes = json.load(f)
    

for uid, filename in uid_file_pairs.items():
    # Locating and Reading SQL File 
    with open(f"diqs/{filename}.sql", "r") as sql_file:
        sql_code = "CREATE FUNCTION" + sql_file.read().split('CREATE FUNCTION', 1)[1]
    
    # Locating and Reading MD File
    with open(f"wikijs/DS{uid[1:3]}/{uid}.md", "r") as md_file:
        md_content = md_file.read()
    
    # Replace existing SQL Block
    new_md_content = re.sub(r'```sql.*?```', f'```sql\n{sql_code}\n```', md_content, flags=re.DOTALL)

    # Search for corresponding object in diq_changes
    for obj in diq_changes:
        if obj["UID"] == uid:
            # Retrieve the 'New Value' from changes array
            change_description = obj["changes"][0]["New Value"]
            break
    
    # Markdown for change log
    change_log = f"\n### Changelog\n\n| Date       | Description of Changes   |\n| ---------- | ------------------------ |\n| 2024-04-30 | {change_description} |\n"

    # Append changelog to the markdown content
    new_md_content += change_log
    
    # Writing back to the MD File
    with open(f"wikijs/DS{uid[1:3]}/{uid}.md", "w") as md_file:
        md_file.write(new_md_content)
