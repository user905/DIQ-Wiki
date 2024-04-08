# DS10
This data set should be populated with the project's contractor project change control log transaction data for DS09. Provide the contractor approved project change control log transaction data by CC_log identifier. The data should consist of CC_logs, each resulting in zero-sum of dollars that are moved between the transaction categories, unless new budget is added to the CBB.

| ------------ | ----------- |
| transaction_ID | Unique transaction identifier. |
| category | Transaction category selection:<br/> • CNT = DOE contingency<br/> • DB = distributed budget (should also be identified by the CA WBS)<br/> • UB = undistributed budget account<br/> • MR = management reserve account<br/> • OTB = over-target baseline only<br/> • OTS = over-target schedule only<br/> • OTB-OTS = OTB and OTS<br/> • funding<br/> • profit-fee |
| CC_log_ID | CC identifier. |
| description | Transaction summary information. |
| WBS_ID | WBS identifier.<br/>Project level required for UB, MR, CNT. <br/> CA or lower level required if transaction type is DB. |
| dollars_delta | CC_log impact (dollars) that changes the balance. |
| hours_delta | CC_log impact (hours) that changes the balance. |
| AUW | Transaction is for AUW. |
| NTE_dollars_delta | NTE for DS10.AUW_dollars |
| POP_start_date | CA or WP WBS POP start date, only if modified. |
| POP_finish_date | CA or WP WBS POP finish date, only if modified. |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
