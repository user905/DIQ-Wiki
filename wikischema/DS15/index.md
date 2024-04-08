# DS15
This data set should be populated with the project's contractor risk log for the entire span of the project (not the contract). Provide the contractor risk log by risk identifier. The data should be updated through the CPP_status_date.

| ------------ | ----------- |
| risk_ID | Unique risk identifier. |
| revision | Current revision number for the DS15.risk_ID |
| description | Risk description.<br/> Format: if then. |
| type | Risk type selection:<br/> • T = threat<br/> • O = opportunity |
| manager | Risk manager.<br/>Format: [last name] space [first name] space [middle initial, optional]. |
| owner | Risk owner selection:<br/> • federal<br/> • contractor |
| approved_date | Approved date with risk handling selection. |
| realized_date | Date risk realized. |
| closed_date | Risk closed date when risk is no longer actively tracked but remains on the risk log. |
| probability_schedule_min_pct | Risk event probability schedule min. (percent). |
| probability_schedule_max_pct | Risk event probability schedule max. (percent). |
| probability_cost_min_pct | Risk event probability cost min. (percent). |
| probability_cost_max_pct | Risk event probability cost max. (percent). |
| risk_handling | Risk handling selections:<br/> • avoid<br/> • mitigate<br/> • transfer<br/> • accept |
| basis | Notes. |
| expected_errors | For use only for debugging and testing with the PARS support team. This field should be omitted in production data.<br/> The field should consist of a comma seperated list of unique DIQ identifiers that this row of data is expected to trigger. |
