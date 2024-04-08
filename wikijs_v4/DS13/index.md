## [ERROR](/DIQs/error)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1130538](/DIQs/DS13/1130538) | Duplicate Subcontract Task | Is this subcontract task duplicated by subcontract ID, subcontract PO ID, & task ID? | Count of subK_id, subK_task_id, & task_ID combo > 1. |
## [WARNING](/DIQs/warning)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1130502](/DIQs/DS13/1130502) | ACWP Dollars Missing | Is ACWP missing on this subcontract? | ACWPc_dollars missing or 0. |
| [1130503](/DIQs/DS13/1130503) | BAC Dollars Missing | Is BAC missing on this subcontract? | BAC_dollars missing or 0. |
| [1130504](/DIQs/DS13/1130504) | BAC Initial Dollars Missing | Are BAC initial dollars missing on this subcontract? | BAC_initial_dollars missing or 0. |
| [1130505](/DIQs/DS13/1130505) | BCWP Dollars Missing | Is BCWP missing on this subcontract? | BCWPc_dollars missing or 0. |
| [1130506](/DIQs/DS13/1130506) | BCWS Dollars Missing | Is BCWS missing on this subcontract? | BCWSc_dollars missing or 0. |
| [1130507](/DIQs/DS13/1130507) | EAC Dollars Missing | Is EAC missing on this subcontract? | EAC_dollars missing or 0. |
| [1130508](/DIQs/DS13/1130508) | MR Dollars Missing | Is MR missing on this subcontract? | MR_dollars missing or 0. |
| [1130509](/DIQs/DS13/1130509) | MR Initial Dollars Missing | Is MR Initial missing on this subcontract? | MR_initial_dollars missing or 0. |
| [1130510](/DIQs/DS13/1130510) | Profit Fee Dollars Missing | Are profit fee dollars missing on this subcontract? | profit_fee_dollars missing or 0. |
| [1130511](/DIQs/DS13/1130511) | Profit Fee Earned Dollars Missing | Are profit fee earned dollars missing on this subcontract? | profit_fee_earned_dollars missing or 0. |
| [1130512](/DIQs/DS13/1130512) | Profit Fee Initial Dollars Missing | Are profit fee initial dollars missing on this subcontract? | profit_fee_initial_dollars missing or 0. |
| [1130513](/DIQs/DS13/1130513) | Actual Finish Without Actual Start | Is this subcontract with actual finish date missing an actual start? | AF_date found without AS_date. |
| [1130517](/DIQs/DS13/1130517) | Actual Finish After Actual Start | Is the actual start after the actual finish? | AS_date > AS_date. |
| [1130523](/DIQs/DS13/1130523) | Missing BL Finish | Is the baseline finish date missing? | BL_finish_date is missing. |
| [1130524](/DIQs/DS13/1130524) | BL Start After BL Finish | Is the baseline start date after the baseline finish? | BL_start_date > BL_finish_date. |
| [1130526](/DIQs/DS13/1130526) | Missing BL Start | Is the baseline start date missing? | BL_start_date is missing. |
| [1130527](/DIQs/DS13/1130527) | Complete Subcontract Missing Actual Finish | Is this 100% complete subcontract missing an actual finish date? | BCWPc_dollars / BAC_dollars = 1 & AF_date missing. |
| [1130531](/DIQs/DS13/1130531) | Missing FC Finish | Is the forecast finish missing? | FC_finish_date missing. |
| [1130532](/DIQs/DS13/1130532) | FC Start After FC Finish | Is the forecast start date after the forecast finish? | FC_start_date > FC_finish_date. |
| [1130534](/DIQs/DS13/1130534) | Missing FC Start | Is the forecast start missing? | FC_start_date missing. |
| [1130535](/DIQs/DS13/1130535) | Missing Flow Down | Is the flow down missing? | flow_down is missing or blank. |
| [1130536](/DIQs/DS13/1130536) | Actuals Without Actual Start | Is this subcontract with ACWP missing an actual start date? | ACWPc_dollars > 0 & AS_date missing. |
| [9130514](/DIQs/DS13/9130514) | ACWP Misaligned With Cost (CA) | Are the actuals for this subcontract misaligned with what is in cost? | ACWPc_dollars <> sum of DS03.ACWPi_dollars where EOC = Subcontract (by DS01.WBS_ID, DS01.parent_WBS_ID, FC DS04.WBS_ID, & DS03.WBS_ID_CA). |
| [9130515](/DIQs/DS13/9130515) | ACWP Misaligned With Cost (WP) | Are the actuals for this subcontract misaligned with what is in cost? | ACWPc_dollars <> sum of DS03.ACWPi_dollars where EOC = Subcontract (by FC DS04.WBS_ID & DS03.WBS_ID_WP). |
| [9130519](/DIQs/DS13/9130519) | BAC Misaligned With Cost (WP) | Is the budget for this subcontract misaligned with what is in cost? | BAC_dollars <> sum of DS03.BCWSi_dollars where EOC = Subcontract (by FC DS04.WBS_ID & DS03.WBS_ID_WP). |
| [9130520](/DIQs/DS13/9130520) | BCWP Misaligned With Cost (WP) | Is the performance for this subcontract misaligned with what is in cost? | BCWPc_dollars <> sum of DS03.BCWPi_dollars where EOC = Subcontract (by FC DS04.WBS_ID & DS03.WBS_ID_WP). |
| [9130521](/DIQs/DS13/9130521) | BCWS Misaligned With Cost (WP) | Is the cumulative budget for this subcontract misaligned with what is in cost? | BCWSc_dollars <> sum of DS03.BCWSi_dollars where EOC = Subcontract & period_date <= CPP_Status_Date (by FC DS04.WBS_ID & DS03.WBS_ID_WP). |
| [9130528](/DIQs/DS13/9130528) | EAC Misaligned With Cost (CA) | Is the estimate at completion for this subcontract misaligned with what is in cost? | EAC_dollars <> sum of DS03.ACWPi_dollars + DS03.ETCi_dollars where EOC = Subcontract (by DS01.WBS_ID, DS01.parent_WBS_ID, FC DS04.WBS_ID, & DS03.WBS_ID_CA). |
| [9130529](/DIQs/DS13/9130529) | EAC Misaligned With Cost (WP) | Is the estimate at completion for this subcontract misaligned with what is in cost? | EAC_dollars <> sum of DS03.ACWPi_dollars + DS03.ETCi_dollars where EOC = Subcontract (by FC DS04.WBS_ID & DS03.WBS_ID_WP). |
| [9130537](/DIQs/DS13/9130537) | Task ID Missing in Forecast Schedule | Is this task id missing in the forecast schedule? | task_ID not in DS04.task_ID where schedule_type = FC. |
| [9130538](/DIQs/DS13/9130538) | Task ID Missing in Labor Resources | Is this task id missing in the forecast labor resources? | task_ID not in DS06.task_ID where EOC = Labor & schedule_type = FC. |
## [ALERT](/DIQs/alert)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1130537](/DIQs/DS13/1130537) | EAC Dollars > BAC Dollars | Is the EAC greater than the BAC on this subcontract? | EAC_dollars > BAC_dollars. |
| [9130516](/DIQs/DS13/9130516) | Actual Finish Misaligned with Forecast Schedule | Is the actual finish date misaligned with the actual finish in the forecast schedule? | AF_date <> DS04.AF_date where schedule_type = FC (by task_ID). |
| [9130518](/DIQs/DS13/9130518) | Actual Start Misaligned with Forecast Schedule | Is the actual start date misaligned with the actual start in the forecast schedule? | AS_date <> DS04.AS_date where schedule_type = FC (by task_ID). |
| [9130522](/DIQs/DS13/9130522) | BL Finish Misaligned with Baseline Schedule | Is the baseline finish date misaligned with the early finish in the baseline schedule? | BL_finish_date <> DS04.EF_date where schedule_type = BL (by task_ID). |
| [9130525](/DIQs/DS13/9130525) | BL Start Misaligned with Baseline Schedule | Is the baseline start date misaligned with the early start in the baseline schedule? | BL_start_date <> DS04.ES_date where schedule_type = BL (by task_ID). |
| [9130530](/DIQs/DS13/9130530) | FC Finish Misaligned with Forecast Schedule | Is the forecast finish date misaligned with the early finish in the forecast schedule? | FC_finish_date <> DS04.EF_date where schedule_type = FC (by task_ID). |
| [9130533](/DIQs/DS13/9130533) | FC Start Misaligned with Forecast Schedule | Is the forecast start date misaligned with the early start in the forecast schedule? | FC_start_date <> DS04.ES_date where schedule_type = FC (by task_ID). |
