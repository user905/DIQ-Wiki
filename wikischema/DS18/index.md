# DS18
This data set should be populated with the project's contractor task EU data for each DS04.task_ID.<br/>Provide the contractor schedule EU data.

| ------------ | ----------- |
| schedule_type | Schedule type selection:<br/> • BL = baseline<br/> • FC = forecast |
| task_ID | Unique task identifier. |
| EU_min_days | EU min. (work days) remaining. |
| EU_likely_days | EU most likely (work days) work remaining. |
| EU_max_days | EU max. (work days) work remaining. |
| justification_EU | Basis.<br/> Add justification narrative if activity is incomplete and task EU distribution is not triangular. |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
