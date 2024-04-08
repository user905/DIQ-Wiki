# PARS CPP JSON Schema v4-0-0
##Key Links:##

 - Official pdf specification: [DOE CPP Upload Requirements including DID](https://json.pars.doe.gov/DID_V04.00_2023-03-22.pdf)
 - JSON Schema file for technical implementation: [DOE CPP Upload Requirements including DID](https://json.pars.doe.gov/pars-cpp-json-schema-v4-0-0.json)
 - JSON Schema Validator to test files: [JSON Validator](https://json-tools.pars.doe.gov/)
 - [How to view a PARS JSON File in Excel](https://json.pars.doe.gov/view_json_in_excel.html) 

##Purpose##

This schema provides a practical framework to facilitate creating a data file that meets the PARS CPP upload requirements per DOE O 413.3B and the CRD.
 This JSON Schema provides a machine-readable implementation of the PARS CPP Upload DID suitable for software development, a human readable DID that is formally approved by PM is also available. This schema is the same one used to validate JSON files uploaded into PARS, but additional data quality checks take place within the PARS application. 

##Summary##

 A JSON Schema is a document that describes the layout, shape, and data contents of a JSON data file. This JSON Schema describes how to format cost, schedule, and other EVMS data for upload into PARS. JSON data uploaded into PARS is required to validate against this Schema.
 This schema is managed by the PARS Support Team who are responsible for the technical ingestion of PARS uploads. Please contact the PARS Support Team at support@pars.doe.gov if you have any questions. 


##How to use this document##

 - The webpage you are currently reading is automatically generated from the JSON schema file and serves as an easy-to-read reference to the data structures and validation requirements.
 

###Update Notes###

 - ADDITIONs denote that the new schema will accept all previously valid data.
 - REVISIONs denote that the new schema will accept some previously accepted data but may introduce incompatibilities in some cases.
 - MODELs are fully backwards-incompatible changes and previously valid data will not be accepted.
 Please see [SchemaVer](https://snowplowanalytics.com/blog/2014/05/13/introducing-schemaver-for-semantic-versioning-of-schemas/) for more details and examples.
 Release notes can be found [here](https://pars-cpp-json.releasenotes.io/).

| Property | Description |
| -------- | ----------- |
| [$schema](wikischema/$schema/index.md) | The JSON schema for this object. This should always be set to the ID of this schema document. |
| [PARSID](wikischema/PARSID/index.md) | PARS identifier for the project for which data is submitted. Should look like a 1-4 digit integer, but is a string. |
| [CPP_status_date](wikischema/CPP_status_date/index.md) | Contractor data-as-of-date. |
| [DS01](wikischema/DS01/index.md) | This data set should be populated with the project's contractor WBS identifiers for the entire span of the project (not the contract).
 Provide the contractor WBS identifiers in a hierarchical structure from the project (not the contract) level to the CA WBS level and to the WP and PP WBS levels. The data set should include all WBS identifiers in all other DSs in the same format. |
| [DS02](wikischema/DS02/index.md) | This data set should be populated with the project's contractor functionally-based OBS identifiers for the entire span of the project (not the contract).
 Provide the contractor OBS identifiers in a hierarchical structure from the project level to the CA WBS level.
 The data should include all OBS identifiers in all other DSs in the same format. The data should align with dollarized RAM identifying intersections of CA WBS and OBS types. |
| [DS03](wikischema/DS03/index.md) | This data set should be populated with the project's contractor EVMS cost tool time-phased data for the entire span of the project (not the contract).
 Provide the contractor EVMS cost tool time-phased data at the WP and PP WBS level by EOC.
 The data should be provided at the WP, PP, and SLPP WBS levels only with one period_date/WBS/EOC record; however, provide at CA WBS level for only those CAs where ACWP (DS03.ACWPi_dollars and DS03.ACWPi_units) is reported for entire project. |
| [DS04](wikischema/DS04/index.md) | This data set should be populated with the project's contractor BL and FC IMS tool data for the entire span of the project (not the contract).
 Provide the contractor BL and FC IMS tool data by task.
 There should be alignment between the BL and FC IMSs. |
| [DS05](wikischema/DS05/index.md) | This data set should be populated with the project's contractor BL and FC IMS tool task relationship data for the DS04 tasks. The contractor BL and FC IMS tool task relationship data by task and predecessor. There should be alignment between the BL and FC IMSs. |
| [DS06](wikischema/DS06/index.md) | This data set should be populated with the project's contractor BL and FC IMS tool task role and resource data for the DS04 tasks.
Provide the contractor BL and FC IMS tool task role and/or resource data by task.
There should be alignment between the BL and FC IMSs. |
| [DS07](wikischema/DS07/index.md) | This object should be populated with the project's contractor IPMR header data aligned with DS01 to DS06 and DS09 to DS12. Provide the contractor EVMS cost tool IPMR header data. This object contains IPMR header information so does not have an array of objects like other DS objects. |
| [DS08](wikischema/DS08/index.md) | This data set should be populated with the approved project's contractor WAD data for the entire span of the project (not the contract) to include from initial and all revisions.
The contractor WAD data by CA and SLPP WBS level and optional by PP and WP WBS levels. |
| [DS09](wikischema/DS09/index.md) | This data set should be populated with the project's contractor project change control log data for the entire span of the project (not the contract).
Provide the contractor approved project change control log data by CC_log identifer.
The data should include the initial CC_log and the initial deposit at the start of the project. |
| [DS10](wikischema/DS10/index.md) | This data set should be populated with the project's contractor project change control log transaction data for DS09. Provide the contractor approved project change control log transaction data by CC_log identifier. The data should consist of CC_logs, each resulting in zero-sum of dollars that are moved between the transaction categories, unless new budget is added to the CBB. |
| [DS11](wikischema/DS11/index.md) | This data set should be populated with the project's contractor variance data. Provide the contractor variance data by WBS identifier; for project, use the project level WBS identifier. |
| [DS12](wikischema/DS12/index.md) | This data set should be populated with the project's contractor corrective action data for DS11.
Provide the contractor corrective action data by corrective action identifier.
The data should validate that corrective actions for variances are addressed, monitored, and mitigated.
The data may be limited to the corrective actions that are open or closed within the current reporting period, based on coordination with DOE. |
| [DS13](wikischema/DS13/index.md) | This data set should be populated with the project's subcontract work data as reported by the subcontractors to the contractor.
 The data should include all subcontracts that have discrete work and that have schedule or cost reporting requirements.
The data should be updated as subcontracts are negotiated.
The data may be limited to a single line per subcontract due to type or size of the subcontract or data availability, based on coordination with DOE. |
| [DS14](wikischema/DS14/index.md) | This data set should be populated with the project's contractor HDV-CI data. Provide the contractor HDV-CI data by WBS and HDV-CI identifiers. |
| [DS15](wikischema/DS15/index.md) | This data set should be populated with the project's contractor risk log for the entire span of the project (not the contract). Provide the contractor risk log by risk identifier. The data should be updated through the CPP_status_date. |
| [DS16](wikischema/DS16/index.md) | This data set should be populated with the project's contractor risk log tasks for the entire span of the project (not the contract).
Provide the contractor risk log tasks by risk identifier.
The data should be updated through the CPP_status_date. |
| [DS17](wikischema/DS17/index.md) | This data set should be populated with the project's contractor WBS EU data for each DS01.WBS and basis documented. Provide the contractor WBS EU data. |
| [DS18](wikischema/DS18/index.md) | This data set should be populated with the project's contractor task EU data for each DS04.task_ID.
Provide the contractor schedule EU data. |
| [DS19](wikischema/DS19/index.md) | This data set should be populated with the project's contractor IMS tool standard work week calendar data for the entire span of the project (not the contract).
 Each weekday is limited to 3 shifts (A, B, and C) for breaks in between shifts, starting with shift A, half hour increments, and no overlaps.
 If more than 3 shifts, 3rd shift should be stretched to the last shift.
 There should be alignment between the BL and FC IMSs. |
| [DS20](wikischema/DS20/index.md) | This data set should be populated with the project's contractor IMS tool calendar exception data for the entire span of the project (not the contract).
 Exception day is limited to 3 shifts (A, B, and C) for breaks in between shifts, starting with shift A, half hour increments, and no overlaps.
 If more than 3 shifts, 3rd shift should be stretched to the last shift.
 There should be alignment between the BL and FC IMSs. |
| [DS21](wikischema/DS21/index.md) | This data set should be populated with the project's contractor EVMS cost tool resource rates.
Provide the contractor EVMS cost tool resource rates by WP WBS level, resource identifier, and applicable FYs.
The data may be UCNI. |
