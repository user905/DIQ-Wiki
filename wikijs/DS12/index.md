## CRITICAL

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1120502](/DIQs/DS12/1120502) | Duplicate VAR CAL Entry | Is this VAR CAL entry duplicated by CAL ID & transaction ID? | Count of CAL_ID & transaction_ID combo > 1. |
## MAJOR

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1120497](/DIQs/DS12/1120497) | Closed Date Before Original Due Date | Is the closed date for this corrective action before the original due date? | closed_date < original_due_date. |
| [1120498](/DIQs/DS12/1120498) | Initial Date After Original Due Date | Is the initial date for this corrective action after the original due date? | initial_date > original_due_date. |
| [1120499](/DIQs/DS12/1120499) | Original Due Date After Forecast Due Date | Is the original due date for this corrective action after the forecast due date? | original_due_date > forecast_due_date. |
| [1120500](/DIQs/DS12/1120500) | Duplicate Transaction ID | Is the transaction ID on this corrective action duplicated? | Count of transaction_ID > 1. |
| [1120501](/DIQs/DS12/1120501) | Transaction ID Missing | Is the transaction ID missing? | transaction_ID blank or missing. |
| [9120496](/DIQs/DS12/9120496) | CAL ID Missing in Variance CAL ID List | Is this CAL missing in the variance CAL list? | CAL_ID not in DS11.CAL_ID list. |
