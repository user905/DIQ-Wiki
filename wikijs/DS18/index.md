## CRITICAL

| UID                           | Title                      | Summary                                                         | Error Message                               |
| ----------------------------- | -------------------------- | --------------------------------------------------------------- | ------------------------------------------- |
| [1180590](/DIQs/DS18/1180590) | Duplicate Schedule EU Task | Is this schedule EU task duplicated by task ID & schedule type? | Count of task_ID & schedule_type combo > 1. |

## MINOR

| UID                           | Title                                       | Summary                                                                                                                              | Error Message                                                                                                                    |
| ----------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| [1180585](/DIQs/DS18/1180585) | Schedule EU Justification Missing           | Is the EU justification missing to explain why the min EU days equal the likely, the likely equal the max, or the min equal the max? | justification_EU is missing or blank & EU_min_days = EU_likely_days, EU_likely_days = EU_max_days, or EU_max_days = EU_min_days. |
| [1180586](/DIQs/DS18/1180586) | Schedule EU Lacking Spread                  | Are the EU minimum, likely, and maximum days all equal?                                                                              | EU_min_days = EU_likely_days = EU_max_days.                                                                                      |
| [1180587](/DIQs/DS18/1180587) | EU Likely Days Greater Than Max             | Are the EU likely days greater than the max days?                                                                                    | EU_likely_days > EU_max_days.                                                                                                    |
| [1180589](/DIQs/DS18/1180589) | EU Minimum Days Greater Than Likely         | Are the EU minimum days greater than the likely days?                                                                                | EU_min_days > EU_likely_days.                                                                                                    |
| [9180588](/DIQs/DS18/9180588) | EU Maximum Days Less Than Original Duration | Are the EU maximum days for this task less than the original duration?                                                               | EU_max_days < DS04.duration_original_days by schedule_type, task_ID, and subproject_ID.                                          |
| [9180591](/DIQs/DS18/9180591) | Schedule EU Task Missing in Schedule        | Is this schedule EU task missing in its respective schedule?                                                                         | task_ID not in DS04.task_ID list (by schedule_type, task_ID, and subproject_ID).                                                 |

