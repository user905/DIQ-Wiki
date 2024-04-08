# DS16
This data set should be populated with the project's contractor risk log tasks for the entire span of the project (not the contract).<br/>Provide the contractor risk log tasks by risk identifier.<br/>The data should be updated through the CPP_status_date.

| ------------ | ----------- |
| risk_ID | Risk identifier.<br/>Align with DS15.risk_ID. |
| risk_task_type | Risk task type selections:<br/> • event (risk trigger, when risk is relevant. If no event task for a risk_ID, then assume risk is relevant for the entire project.)<br/> • impact |
| task_ID |  Event or impact task identifer.<br/> Aligned with DS04.task_ID and based on DS16.risk_task_type. |
| impact_schedule_min_days | Provide if DS16.risk_task_type = impact, schedule impact (calendar days) min. |
| impact_schedule_likely_days | Provide if DS16.risk_task_type = impact, schedule impact (calendar days) most likely. |
| impact_schedule_max_days | Provide if DS16.risk_task_type = impact, schedule impact (calendar days) max. |
| impact_cost_min_dollars | Provide if DS16.risk_task_type = impact, cost impact (dollars) min. |
| impact_cost_likely_dollars | Provide if DS16.risk_task_type = impact, cost impact (dollars) most likely. |
| impact_cost_max_dollars | Provide if DS16.risk_task_type = impact, cost impact (dollars) max. |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
