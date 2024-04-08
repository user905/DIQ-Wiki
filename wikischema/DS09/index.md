# DS09
This data set should be populated with the project's contractor project change control log data for the entire span of the project (not the contract).<br/>Provide the contractor approved project change control log data by CC_log identifer.<br/>The data should include the initial CC_log and the initial deposit at the start of the project.

| ------------ | ----------- |
| CC_log_ID | CC identifier. |
| CC_log_ID_supplement | Supplemental CC_log_ID, e.g. revisions. |
| CC_log_ID_original_UB | For CCs that are approving distribution of budget from UB, this should have original CC_log_ID that approved increase of UB account through AUW or modification. |
| type | BCP type selection (per DOE EVMS glossary):<br/>• Funding <br/> • BCP <br/> • BCR |
| K_mod_ID | Provide when CC_log_ID is associated with a contract mod. |
| description | Scope description. (Do not include unapproved changes) |
| approved_date | Approved date. |
| implementation_date | Date during which the change has been implemented within contractor systems. |
| dollars_delta | Total increase or decrease in CA WBS budgeted dollars authorized by the change request. |
| hours_delta | Total increase or decrease in CA WBS budgeted number of hours authorized by the change request. |
| PM | Contractor project manager.<br/>Format: [last name] space [first name] space [middle initial, optional] |
| risk_ID | List of risk_IDs addressed by CC_log_ID.<br/> Aligns with DS15.risk_ID.<br/>If multple identifiers, seperate with semicolons. |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
