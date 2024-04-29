## CRITICAL

| UID                           | Title                        | Summary                                                                               | Error Message                                                      |
| ----------------------------- | ---------------------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| [1200595](/DIQs/DS20/1200595) | Duplicate Calendar Exception | Is this calendar exception duplicated by calendar name, subproject, & exception date? | Count of calendar_name, subproject_ID, & exception_date combo > 1. |

## MINOR

| UID                           | Title                                           | Summary                                                     | Error Message                                                                                     |
| ----------------------------- | ----------------------------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| [1200597](/DIQs/DS20/1200597) | Non-Workday Exception Missing Shift             | Is this non-workday exception missing a shift?              | exception*work_day = N & no exception_shift*#_start_time or exception_shift_#\_finish_time found. |
| [1200598](/DIQs/DS20/1200598) | Shift Exception In Excess Of 12 Hours           | Is this shift exception longer than 12 hours?               | Delta between exception*shift*#_start_time & exception_shift_#\_finish_time found > 12.           |
| [9200596](/DIQs/DS20/9200596) | Calendar Name Missing In Standard Calendar List | Is this calendar missing in the standard list of calendars? | calendar_name not in DS19.calendar_name list.                                                     |

