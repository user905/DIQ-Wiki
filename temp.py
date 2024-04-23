import csv
import json
from collections import defaultdict
to_create = {
    "9060304": "fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollarsCA",
    "9060305": "fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollarsWP",
    "1030113": "fnDIQ_DS03_Cost_IsODCComingledWithNonIndirectEOCs",
    "1030117": "fnDIQ_DS03_Cost_IsLaborComingledWithNonIndirectEOCs",
    "9060306": "fnDIQ_DS06_Res_AreDS03ADollarsMissingResourcePDollarsCA",
    "9060307": "fnDIQ_DS06_Res_AreDS03LaborAHoursMissingResourceLaborPUnitsCA",
    "9080411": "fnDIQ_DS08_WAD_AreIndirectDollarsMisalignedWithDS03CA",
    "1060269": "fnDIQ_DS03_Cost_IsCAWBSEqTWPWBS",
    "1030111": "fnDIQ_DS03_Cost_IsIndirectBCWSMissingFromProject",
    "1030094": "fnDIQ_DS03_Cost_IsIndirectInsufficient",
    "1030095": "fnDIQ_DS03_Cost_IsMatComingledWithNonIndirectEOCs",
    "1030112": "fnDIQ_DS03_Cost_IsSubKComingledWithNonIndirectEOCs",
    "1030098": "fnDIQ_DS03_Cost_IsIndirectWorkMissingOtherEOCTypes",
    "9080433": "fnDIQ_DS08_WAD_IsIndirectBudgetMissingInDS03WP",
    "9080434": "fnDIQ_DS08_WAD_IsIndirectBudgetMissingInDS03CA",
    "9080410": "fnDIQ_DS08_WAD_AreIndirectDollarsMisalignedWithDS03WP",
    "9060302": "fnDIQ_DS06_Res_AreLaborPUnitsMissingDS03LaborAHoursWP",
    "9060303": "fnDIQ_DS06_Res_AreLaborPUnitsMissingDS03LaborAHoursCA",
    "1060262": "fnDIQ_DS06_Res_IsIndirectUsedUnevenly",
    "1060264": "fnDIQ_DS06_Res_AreEOCsComingled",
    "1060265": "fnDIQ_DS06_Res_IsResourceMissingEOC",
    "1060266": "fnDIQ_DS06_Res_IsResourceDuplicated",
    "1060267": "fnDIQ_DS06_Res_DoesIndirectHaveUnits",
    "1030114": "fnDIQ_DS03_Cost_DoesIndirectHaveHoursOrFTEs",
    "1030115": "fnDIQ_DS03_Cost_IsIndirectCollectedImproperly",
    "1030116": "fnDIQ_DS03_Cost_IsIndirectUseInconsistent",
    "9050283": "fnDIQ_DS05_Logic_IsLOESuccessorRelEqToFF"
}

# Load diq_data.json
with open('diq_data.json') as f:
    data = json.load(f)

ds_tables = defaultdict(list)

for key, value in enumerate(data.items()):
    if value[0] in to_create.values():  
        print(value[0])

# for key, diag in data.items():
#     print (key)
#     # Skip this iteration if value[0] is not in to_create.values()
#     if key not in to_create.values():
#         continue
#     # Exclude all rows where status = DELETED
#     if diag["status"] != "DELETED":
#         # Add each diag to its respective DS' list
#         ds_tables[diag["table"].split(" ")[0]].append(diag)

# regular_dict = dict(ds_tables)

# fields = set()

# # Extract fields (keys) from every dictionary in the data structure.
# for k,v in regular_dict.items():
#     for dic in v:
#         for key in dic.keys():
#             fields.add(key)

# # Convert set to list to use as field names
# headers = list(fields)

# with open('ds_tables.csv', 'w') as csv_file:
#     writer = csv.DictWriter(csv_file, fieldnames=headers)
#     writer.writeheader()
#     for k, v in regular_dict.items():
#         for dic in v:
#             writer.writerow(dic)