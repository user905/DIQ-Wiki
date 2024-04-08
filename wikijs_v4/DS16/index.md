## [ERROR](/DIQs/error)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1160569](/DIQs/DS16/1160569) | Duplicate Risk Task | Is this risk task duplicated by risk ID & task ID? | Count of combo of risk_ID & task_ID > 1. |
## [WARNING](/DIQs/warning)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1160565](/DIQs/DS16/1160565) | Impact Cost Dollar Spread Missing | Are the minimum, likely, and max impact cost dollars all equivalent? | impact_cost_minimum_dollars = impact_cost_likely_dollars = impact_cost_max_dollars. |
| [1160568](/DIQs/DS16/1160568) | Impact Schedule Day Spread Missing | Are the minimum, likely, and max impact schedule days all equivalent? | impact_schedule_minimum_days = impact_schedule_likely_days = impact_schedule_max_days. |
| [9160570](/DIQs/DS16/9160570) | Risk ID Missing In Risk Log | Is this risk ID missing in the risk log? | Risk_ID not in DS15.risk_ID list. |
| [9160571](/DIQs/DS16/9160571) | Task ID Missing in Baseline Schedule | Is this task ID missing in the baseline schedule? | task_ID not in DS04.task_ID list where schedule_type = BL. |
| [9160572](/DIQs/DS16/9160572) | Task ID Missing in Forecast Schedule | Is this task ID missing in the forecast schedule? | task_ID not in DS04.task_ID list where schedule_type = FC. |
## [ALERT](/DIQs/alert)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1160561](/DIQs/DS16/1160561) | Event With Impact | Does this event task have an impact value on cost and/or schedule? | risk_task_type = Event & non-zero value found in impact_schedule_min_days, impact_schedule_likely_days, impact_schedule_max_days, impact_cost_min_dollars, impact_cost_likely_dollars, or impact_cost_max_dollars. |
| [1160562](/DIQs/DS16/1160562) | Impact Missing Impact Value | Is this impact task missing an impact value on cost and/or schedule? | risk_task_type = Impact & value missing on at least one of impact_schedule_min_days, impact_schedule_likely_days, impact_schedule_max_days, impact_cost_min_dollars, impact_cost_likely_dollars, or impact_cost_max_dollars. |
| [1160563](/DIQs/DS16/1160563) | Likely Impact Cost Dollars Greater Than Max Dollars | Are the likely impact dollars for cost greater than the max impact dollars? | impact_cost_likely_dollars > impact_cost_max_dollars. |
| [1160564](/DIQs/DS16/1160564) | Minimum Impact Cost Dollars Greater Than Likely Dollars | Are the minimum impact dollars for cost greater than the likely impact dollars? | impact_cost_minimum_dollars > impact_cost_likely_dollars. |
| [1160566](/DIQs/DS16/1160566) | Likely Impact Schedule Days Greater Than Max Days | Are the likely impact days for schedule greater than the max impact days? | impact_schedule_likely_days > impact_schedule_max_days. |
| [1160567](/DIQs/DS16/1160567) | Minimum Impact Schedule Days Greater Than Likely Days | Are the minimum impact days for schedule greater than the likely impact days? | impact_schedule_minimum_days > impact_schedule_likely_days. |
