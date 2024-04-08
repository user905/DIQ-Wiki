## [ERROR](/DIQs/error)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1150559](/DIQs/DS15/1150559) | Risk Duplicated | Is this risk duplicated by risk ID & revision? | Count of risk_ID & revision combo > 1. |
## [WARNING](/DIQs/warning)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1150556](/DIQs/DS15/1150556) | Probability Schedule Min Equal To Or Above 98% | Is the minimum probability schedule percent equal to or above 98%? | probability_schedule_min_pct >= .98. |
| [1150561](/DIQs/DS15/1150561) | Probability Cost Min Equal To Or Above 98% | Is the minimum probability cost percent equal to or above 98%? | probability_cost_min_pct >= .98. |
| [9150560](/DIQs/DS15/9150560) | Risk Missing Impact Task | Is this risk missing an impact task in the risk log? | risk_ID not in DS16.task_ID list where risk_task_type = Impact. |
## [ALERT](/DIQs/alert)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1150548](/DIQs/DS15/1150548) | Opportunity With Avoid Or Transfer Handling Type | Does this opportunity have an avoid or transfer handling type? | type = O & risk_handling = Avoid or Transfer. |
| [1150549](/DIQs/DS15/1150549) | Approved Date After Closed Date | Is the approved date after the closed date? | approved_date > closed_date. |
| [1150550](/DIQs/DS15/1150550) | Approved Date After Realized Date | Is the approved date after the realized date? | approved_date > realized_date. |
| [1150553](/DIQs/DS15/1150553) | Probability Cost Min % Greater Than Max % | Is the minimum probability cost percent greater than the max percent? | probability_cost_min_pct > probability_cost_max_pct. |
| [1150554](/DIQs/DS15/1150554) | Probability Cost Min Between 92 - 98% | Is the minimum probability cost percent between 92 & 98%? | probability_cost_min_pct >= .92 & < .98. |
| [1150555](/DIQs/DS15/1150555) | Probability Schedule Min % Greater Than Max % | Is the minimum probability schedule percent greater than the max percent? | probability_schedule_min_pct > probability_schedule_max_pct. |
| [1150557](/DIQs/DS15/1150557) | Probability Schedule Min Between 92 - 98% | Is the minimum probability schedule percent between 92 & 98%? | probability_schedule_min_pct >= .92 & < .98. |
| [1150558](/DIQs/DS15/1150558) | Realized Date After Closed Date | Is the realized date after the closed date? | realized_date > closed_date. |
| [9150551](/DIQs/DS15/9150551) | Risk Closed Before Risk Tasks Have Completed | Is the closed date before all the risk's tasks have finished? | closed_date < FC DS04.EF_date (by DS15.risk_ID & DS16.risk_ID, and DS16.task_ID & DS04.task_ID). |
| [9150552](/DIQs/DS15/9150552) | Risk Mitigation Task Missing In Baseline Schedule | Is this risk mitigation task missing in the baseline schedule? | risk_handling = Mitigate & risk_ID not in BL DS04.RMT_ID list. |
