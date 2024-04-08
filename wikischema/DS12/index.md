# DS12
This data set should be populated with the project's contractor corrective action data for DS11.<br/>Provide the contractor corrective action data by corrective action identifier.<br/>The data should validate that corrective actions for variances are addressed, monitored, and mitigated.<br/>The data may be limited to the corrective actions that are open or closed within the current reporting period, based on coordination with DOE.

| ------------ | ----------- |
| CAL_ID | Corrective action log identifier. |
| transaction_ID | Unique transaction identifier. |
| narrative_schedule | Corrective action narrative for cumulative schedule variance. |
| narrative_cost | Corrective action narrative for cumulative cost variance. |
| POC | Name of the person responsible for closing corrective action.<br/>Does not have to be the same as CAM.<br/>Format: [last name] space [first name] space [middle initial, optional]. |
| status | Current status of corrective action Item as it exists in contractor log.<br/> • open<br/> • closed |
| initial_date | Date of the initial corrective action. |
| original_due_date | Original due date by which corrective action was supposed to be closed. |
| forecast_due_date | Forecast due date that indicates expected closure date for the corrective action. DS12.closed_date if closed. |
| closed_date | Actual date when corrective action was closed. |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
