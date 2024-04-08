# DS13
This data set should be populated with the project's subcontract work data as reported by the subcontractors to the contractor.<br/> The data should include all subcontracts that have discrete work and that have schedule or cost reporting requirements.<br/>The data should be updated as subcontracts are negotiated.<br/>The data may be limited to a single line per subcontract due to type or size of the subcontract or data availability, based on coordination with DOE.

| ------------ | ----------- |
| subK_ID | Unique subcontract identifier (e.g., subcontract name). |
| subK_task_ID | Unique task ID from subcontract schedule. |
| task_ID | DS04.task_ID associated with subcontract work. |
| BCWSc_dollars | BCWS cumulative (dollars). |
| BCWPc_dollars | BCWP cumulative (dollars). |
| ACWPc_dollars | ACWP cumulative (dollars). |
| BAC_dollars | DB (dollars). |
| BAC_initial_dollars | BAC initial (dollars). |
| EAC_dollars | EAC (dollars). |
| BL_start_date | Baseline start date. |
| BL_finish_date | Baseline finish date. |
| FC_start_date | Forecast start date. |
| FC_finish_date | Forecast finish date. |
| AS_date | Actual start date. |
| AF_date | Actual finish date. |
| MR_dollars | MR Remaining (dollars). |
| MR_initial_dollars | MR initial (dollars). |
| profit_fee_dollars | Profit fee remaining (dollars). |
| profit_fee_earned_dollars | Profit fee earned (dollars). |
| profit_fee_initial_dollars | Profit fee initial (dollars). |
| subK_PO_ID | Purchase order identifier. |
| flow_down | DOE Order 413.3B CRD flow down required. |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
