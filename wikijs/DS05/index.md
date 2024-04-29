## CRITICAL

| UID                           | Title                           | Summary                                                                                                              | Error Message                                                                                                 |
| ----------------------------- | ------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| [1050233](/DIQs/DS05/1050233) | Schedule Missing Logic          | Is schedule logic missing for either the BL or FC schedule?                                                          | Zero logic rows found for either the BL or FC schedule (schedule_type = BL or FC).                            |
| [1050236](/DIQs/DS05/1050236) | Non-Unique Relationship         | Is this row duplicated by schedule_type, task_ID, predecessor_task_ID, subproject_ID, and predecessor_subproject_ID? | Count of schedule_type, task_ID, predecessor_task_ID, subproject_ID, and predecessor_subproject_ID combo > 1. |
| [9050281](/DIQs/DS05/9050281) | Predecessor Missing in Schedule | Is this predecessor missing in the schedule?                                                                         | predecessor_task_ID not found in DS04 task_ID list (by schedule_type).                                        |
| [9050282](/DIQs/DS05/9050282) | Task Missing in Schedule        | Is this task missing in the schedule?                                                                                | task_ID not found in DS04 task_ID list (by schedule_type).                                                    |

## MAJOR

| UID                           | Title                                                    | Summary                                                                   | Error Message                                                                                                                            |
| ----------------------------- | -------------------------------------------------------- | ------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| [1050232](/DIQs/DS05/1050232) | Lead                                                     | Is the lag for this task less than zero, i.e. a lead?                     | Lag_days < 0.                                                                                                                            |
| [1050234](/DIQs/DS05/1050234) | SS or FF Improperly Linked With Other Relationship Types | Does this SS or FF relationship exist alongside an FS or SF relationship? | Predecessor has at least one SS or FF relationship (type = SS or FF) and one non-SS or non-FF relationship tied to it (type = SF or FS). |
| [1050235](/DIQs/DS05/1050235) | Start-Finish Relationship                                | Is this a start-finish relationship?                                      | Relationship type is start-finish (type = SF).                                                                                           |

## MINOR

| UID                           | Title                     | Summary                                           | Error Message                                                                                    |
| ----------------------------- | ------------------------- | ------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| [9050280](/DIQs/DS05/9050280) | Lag Missing Justification | Is the lag for this task missing a justification? | Lag_days <> 0 and lacking a justification in DS04 schedule (justification_lag is null or blank). |

