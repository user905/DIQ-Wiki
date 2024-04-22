## DS00

| UID                           | Title                                     | Summary                                                                | Error Message                                      |
| ----------------------------- | ----------------------------------------- | ---------------------------------------------------------------------- | -------------------------------------------------- |
| [1000001](/DIQs/DS00/1000001) | CPP Status Date Missing From Cost Periods | Is the CPP Status Date missing from the period dates in the cost file? | DS00.CPP_Status_Date not in DS03.period_date list. |

## DS01

| UID                           | Title                                     | Summary                                                                                | Error Message                                                                                       |
| ----------------------------- | ----------------------------------------- | -------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| [1010002](/DIQs/DS01/1010002) | WBS Level Contiguity                      | Are the WBS Levels contiguous in the WBS hierarchy?                                    | WBS level is not contiguous with prior levels in the WBS hierarchy.                                 |
| [1010016](/DIQs/DS01/1010016) | CA or SLPP with WP Ancestor               | Is this CA or SLPP at a lower level in the WBS hierarchy than a WP in the same branch? | CA or SLPP found at a lower level in the WBS hierarchy than a WP in the same branch.                |
| [1010017](/DIQs/DS01/1010017) | CA or WBS Without Child                   | Does the Control Account or WBS Type have a child in the WBS hierarchy?                | CA or WBS element missing child.                                                                    |
| [1010025](/DIQs/DS01/1010025) | Parent Lower in WBS Hierarchy than Child  | Is the parent lower in the WBS hierarchy than its child?                               | Parent found at a lower level in the WBS hierarchy than its child, i.e. Parent Level > Child Level. |
| [1010026](/DIQs/DS01/1010026) | Parent WBS ID Missing                     | Is the Parent WBS ID missing?                                                          | Parent WBS ID is missing.                                                                           |
| [1010032](/DIQs/DS01/1010032) | WBS ID Not Unique                         | Is the WBS ID repeated across the WBS hierarchy?                                       | WBS ID is not unique across the WBS hierarchy.                                                      |
| [1010033](/DIQs/DS01/1010033) | Root of WBS hierarchy must be of type WBS | Is the top element of your WBS hierarchy of a type other than WBS?                     | Level 1 WBS element not of type WBS.                                                                |
| [1010034](/DIQs/DS01/1010034) | Root of WBS not unique                    | Is the root of the WBS hierarchy (Level 1) unique?                                     | WBS hierarchy contains more than one Level 1 WBS element.                                           |
| [1010036](/DIQs/DS01/1010036) | WP or PP At Level 1 or 2                  | Is the WP or PP at Level 1 or 2 in the WBS hierarchy?                                  | WP or PP at Level 1 or 2 in the WBS hierarchy                                                       |
| [1010039](/DIQs/DS01/1010039) | Parent WBS ID Missing In WBS List         | Is the Parent WBS ID missing in the WBS ID list?                                       | Parent WBS ID not found in the WBS ID list.                                                         |

## DS02

| UID                           | Title                                    | Summary                                                  | Error Message                                                                                       |
| ----------------------------- | ---------------------------------------- | -------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| [1020039](/DIQs/DS02/1020039) | OBS Levels Not Contiguous                | Are the OBS levels contiguous in the OBS hierarchy?      | OBS level is not contiguous with prior levels in the OBS hierarchy.                                 |
| [1020045](/DIQs/DS02/1020045) | OBS ID Not Unique                        | Is the OBS ID repeated across the OBS hierarchy?         | OBS ID is not unique across the OBS hierarchy.                                                      |
| [1020047](/DIQs/DS02/1020047) | Root of OBS Not Unique                   | Is the root of the OBS hierarchy (Level 1) unique?       | OBS hierarchy contains more than one Level 1 OBS element.                                           |
| [1020048](/DIQs/DS02/1020048) | Parent Lower in OBS Hierarchy than Child | Is the parent lower in the OBS hierarchy than its child? | Parent found at a lower level in the OBS hierarchy than its child, i.e. Parent Level > Child Level. |
| [1020050](/DIQs/DS02/1020050) | Parent OBS ID Missing In OBS List        | Is the Parent OBS ID missing in the OBS ID list?         | Parent OBS ID not found in the OBS ID list.                                                         |

## DS03

| UID                           | Title                                                | Summary                                                                               | Error Message                                                                                                                      |
| ----------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| [1030058](/DIQs/DS03/1030058) | Actuals At CA and WP Level                           | Are actuals collected at both the CA and WP level?                                    | CAs and WPs found with ACWPi <> 0 (Dollars, Hours, or FTEs)                                                                        |
| [1030072](/DIQs/DS03/1030072) | WP or PP with Multiple EVT Groups                    | Does this WP or PP have more than one EVT group?                                      | WP or PP where EVT group is not uniform (EVTs are not all LOE, Discrete, Apportioned, or Planning Package for this WP or PP data). |
| [1030077](/DIQs/DS03/1030077) | Apportioned To WBS ID Missing                        | Is the WBS ID to which this work is apportioned missing?                              | EVT = J or M but EVT_J_to_WBS_ID is missing.                                                                                       |
| [1030106](/DIQs/DS03/1030106) | WP or PP Found Across Multiple CAs                   | Is the WP or PP found across multiple Control Accounts?                               | WBS_ID_WP found across distinct WBS_ID_CA.                                                                                         |
| [1030108](/DIQs/DS03/1030108) | Non-Unique Cost Row                                  | Is this row duplicated by period date, CA WBS ID, WP WBS ID, EOC, EVT, & is_indirect? | Count of period_date, WBS_ID_CA, WBS_ID_WP, EOC, EVT, is_indirect combo > 1.                                                       |
| [9030061](/DIQs/DS03/9030061) | Performance On SLPP, CA, or PP                       | Has this SLPP, CA, or PP collected performance?                                       | SLPP, CA, or PP found with BCWPi <> 0 (Dollars, Hours, or FTEs).                                                                   |
| [9030062](/DIQs/DS03/9030062) | CA with Budget                                       | Does this CA have budget?                                                             | CA found with BCWSi > 0 (Dollars, Hours, or FTEs).                                                                                 |
| [9030078](/DIQs/DS03/9030078) | Apportionment IDs Mismatch Between Cost and Schedule | Is the WBS ID to which this work is apportioned mismatched in cost and schedule?      | EVT = J or M where EVT_J_to_WBS_ID does not equal the WBS ID in Schedule.                                                          |

## DS04

| UID                           | Title                                                | Summary                                                                 | Error Message                                                                                                                                        |
| ----------------------------- | ---------------------------------------------------- | ----------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| [1040117](/DIQs/DS04/1040117) | BL Task With Negative Free Float                     | Does this BL task have negative free float?                             | BL Task with float_free_days < 0.                                                                                                                    |
| [1040118](/DIQs/DS04/1040118) | BL Task With Negative Total Float                    | Does this BL task have negative total float?                            | BL Task with float_total_days < 0.                                                                                                                   |
| [1040139](/DIQs/DS04/1040139) | Activity Missing EVT                                 | Is this activity missing an EVT?                                        | activity where EVT = null or blank (Note: If task is a milestone, then type must be either FM or SM. Otherwise, it will be treated as an activity.). |
| [1040141](/DIQs/DS04/1040141) | Missing Apportioned To Task ID                       | Is this apportioned task missing an apportioned to task ID?             | Apportioned task (EVT = J or M) missing ID in EVT_J_to_task_ID.                                                                                      |
| [1040206](/DIQs/DS04/1040206) | Approve Finish Project Milestone Missing in Baseline | Is your baseline schedule missing the approve finish project milestone? | No row found for approve finish project milestone (milestone_level = 199) in baseline schedule (schedule_type = BL).                                 |
| [1040207](/DIQs/DS04/1040207) | Approve Finish Project Milestone Missing in Forecast | Is your forecast schedule missing the approve finish project milestone? | No row found for approve finish project milestone (milestone_level = 199) in forecast schedule (schedule_type = FC).                                 |
| [1040208](/DIQs/DS04/1040208) | Approve Start Project Milestone Missing in Baseline  | Is your baseline schedule missing the approve start project milestone?  | No row found for approve start project milestone (milestone_level = 100) in baseline schedule (schedule_type = BL).                                  |
| [1040209](/DIQs/DS04/1040209) | Approve Start Project Milestone Missing in Forecast  | Is your forecast schedule missing the approve start project milestone?  | No row found for approve start project milestone (milestone_level = 100) in forecast schedule (schedule_type = FC).                                  |
| [1040210](/DIQs/DS04/1040210) | Schedule Missing                                     | Is your schedule data missing either the BL or FC schedule?             | Zero rows found in either the BL or FC schedule (schedule_type = BL or FC).                                                                          |
| [1040215](/DIQs/DS04/1040215) | Duplicate Task ID                                    | Is this task duplicated in the schedule?                                | Duplicate task ID found (by subproject_ID).                                                                                                          |
| [1040220](/DIQs/DS04/1040220) | WBS Misaligned Between FC & BL                       | Is the WBS ID for this task misaligned between the FC & BL schedules?   | WBS_ID does not align between the FC & BL schedules for this task_ID.                                                                                |

## DS05

| UID                           | Title                           | Summary                                                                                                              | Error Message                                                                                                 |
| ----------------------------- | ------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| [1050233](/DIQs/DS05/1050233) | Schedule Missing Logic          | Is schedule logic missing for either the BL or FC schedule?                                                          | Zero logic rows found for either the BL or FC schedule (schedule_type = BL or FC).                            |
| [1050236](/DIQs/DS05/1050236) | Non-Unique Relationship         | Is this row duplicated by schedule_type, task_ID, predecessor_task_ID, subproject_ID, and predecessor_subproject_ID? | Count of schedule_type, task_ID, predecessor_task_ID, subproject_ID, and predecessor_subproject_ID combo > 1. |
| [9050281](/DIQs/DS05/9050281) | Predecessor Missing in Schedule | Is this predecessor missing in the schedule?                                                                         | predecessor_task_ID not found in DS04 task_ID list (by schedule_type).                                        |
| [9050282](/DIQs/DS05/9050282) | Task Missing in Schedule        | Is this task missing in the schedule?                                                                                | task_ID not found in DS04 task_ID list (by schedule_type).                                                    |

## DS06

| UID                           | Title                             | Summary                                                                                                    | Error Message                                                                             |
| ----------------------------- | --------------------------------- | ---------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| [1060245](/DIQs/DS06/1060245) | Missing Resource & Role ID        | Is this resource missing both a resource and role ID?                                                      | Resource missing both resource_ID and role_ID (resource_ID and role_ID = null or blank).  |
| [1060248](/DIQs/DS06/1060248) | Resource Missing Name             | Is this resource missing a name?                                                                           | Resource found without a resource name (resource_name = null or blank).                   |
| [1060253](/DIQs/DS06/1060253) | Resource Role Missing Name        | Is this resource role missing a name?                                                                      | role_ID is not blank & role_name is blank.                                                |
| [1060254](/DIQs/DS06/1060254) | Schedule Missing Resources        | Is either the BL or FC schedule missing resources?                                                         | Zero resource rows found for either the BL or FC schedule (schedule_type = BL or FC).     |
| [1060259](/DIQs/DS06/1060259) | Non-Unique Resource or Role       | Is this resource / role duplicated by schedule type, task ID, EOC, subproject ID, and resource or role ID? | Count of schedule_type, task_ID, EOC, subproject_ID and resource_ID or role_id combo > 1. |
| [9060299](/DIQs/DS06/9060299) | Resource Missing Rates            | Are the rates missing for this resource?                                                                   | Resource_ID missing in DS21.resource_ID list.                                             |
| [9060301](/DIQs/DS06/9060301) | Resource Task Missing in Schedule | Is the task this resource is assigned to missing in the schedule?                                          | Task_ID missing in DS04.task_ID list (by schedule_type & subproject_ID).                  |

## DS08

| UID                           | Title         | Summary                                                           | Error Message                                             |
| ----------------------------- | ------------- | ----------------------------------------------------------------- | --------------------------------------------------------- |
| [1080441](/DIQs/DS08/1080441) | Duplicate WAD | Is this WAD a duplicate by WAD ID, WBS ID, WP WBS ID, & revision? | Count of WAD_ID, WBS_ID, WBS_ID_WP, & revision combo > 1. |

## DS09

| UID                           | Title                  | Summary                                                       | Error Message                                        |
| ----------------------------- | ---------------------- | ------------------------------------------------------------- | ---------------------------------------------------- |
| [1090440](/DIQs/DS09/1090440) | Duplicate CC Log Entry | Is this CC Log entry duplicated by CC Log ID & Supplement ID? | Count of CC_log_ID & CC_log_ID_supplement combo > 1. |

## DS10

| UID                           | Title                               | Summary                                                   | Error Message                                  |
| ----------------------------- | ----------------------------------- | --------------------------------------------------------- | ---------------------------------------------- |
| [1100478](/DIQs/DS10/1100478) | Duplicate CC Log Detail Transaction | Is the transaction duplicated by transaction & CC log ID? | Count of transaction_ID & CC_log_ID combo > 1. |

## DS11

| UID                           | Title         | Summary                                            | Error Message                               |
| ----------------------------- | ------------- | -------------------------------------------------- | ------------------------------------------- |
| [1110495](/DIQs/DS11/1110495) | Duplicate VAR | Is this VAR duplicated by WBS ID & Narrative type? | Count of WBS_ID & narrative_type combo > 1. |

## DS12

| UID                           | Title                   | Summary                                                      | Error Message                               |
| ----------------------------- | ----------------------- | ------------------------------------------------------------ | ------------------------------------------- |
| [1120502](/DIQs/DS12/1120502) | Duplicate VAR CAL Entry | Is this VAR CAL entry duplicated by CAL ID & transaction ID? | Count of CAL_ID & transaction_ID combo > 1. |

## DS13

| UID                           | Title                      | Summary                                                                              | Error Message                                        |
| ----------------------------- | -------------------------- | ------------------------------------------------------------------------------------ | ---------------------------------------------------- |
| [1130538](/DIQs/DS13/1130538) | Duplicate Subcontract Task | Is this subcontract task duplicated by subcontract ID, subcontract PO ID, & task ID? | Count of subK_id, subK_task_id, & task_ID combo > 1. |

## DS14

| UID                           | Title               | Summary                   | Error Message           |
| ----------------------------- | ------------------- | ------------------------- | ----------------------- |
| [1140543](/DIQs/DS14/1140543) | Duplicate HDV-CI ID | Is the HDV-CI duplicated? | Count of HDV_CI_ID > 1. |

## DS15

| UID                           | Title           | Summary                                        | Error Message                          |
| ----------------------------- | --------------- | ---------------------------------------------- | -------------------------------------- |
| [1150559](/DIQs/DS15/1150559) | Risk Duplicated | Is this risk duplicated by risk ID & revision? | Count of risk_ID & revision combo > 1. |

## DS16

| UID                           | Title               | Summary                                            | Error Message                            |
| ----------------------------- | ------------------- | -------------------------------------------------- | ---------------------------------------- |
| [1160569](/DIQs/DS16/1160569) | Duplicate Risk Task | Is this risk task duplicated by risk ID & task ID? | Count of combo of risk_ID & task_ID > 1. |

## DS17

| UID                           | Title                                | Summary                             | Error Message                       |
| ----------------------------- | ------------------------------------ | ----------------------------------- | ----------------------------------- |
| [1170582](/DIQs/DS17/1170582) | Duplicate Estimate Uncertainty Entry | Is this WBS / EOC combo duplicated? | Count of combo WBS & EOC combo > 1. |

## DS18

| UID                           | Title                      | Summary                                                         | Error Message                               |
| ----------------------------- | -------------------------- | --------------------------------------------------------------- | ------------------------------------------- |
| [1180590](/DIQs/DS18/1180590) | Duplicate Schedule EU Task | Is this schedule EU task duplicated by task ID & schedule type? | Count of task_ID & schedule_type combo > 1. |

## DS19

| UID                           | Title                   | Summary                                          | Error Message            |
| ----------------------------- | ----------------------- | ------------------------------------------------ | ------------------------ |
| [1190593](/DIQs/DS19/1190593) | Duplicate Calendar Name | Is this calendar name duplicated in the dataset? | Count calendar_name > 1. |

## DS20

| UID                           | Title                        | Summary                                                                               | Error Message                                                      |
| ----------------------------- | ---------------------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| [1200595](/DIQs/DS20/1200595) | Duplicate Calendar Exception | Is this calendar exception duplicated by calendar name, subproject, & exception date? | Count of calendar_name, subproject_ID, & exception_date combo > 1. |

## DS21

| UID                           | Title          | Summary                                 | Error Message          |
| ----------------------------- | -------------- | --------------------------------------- | ---------------------- |
| [1210602](/DIQs/DS21/1210602) | Duplicate Rate | Is this rate duplicated by resource ID? | Count resource_ID > 1. |
