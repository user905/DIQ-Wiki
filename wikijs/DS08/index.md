## [ERROR](/DIQs/error)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1080441](/DIQs/DS08/1080441) | Duplicate WAD | Is this WAD a duplicate by WAD ID, WBS ID, WP WBS ID, & revision? | Count of WAD_ID, WBS_ID, WBS_ID_WP, & revision combo > 1. |
## [WARNING](/DIQs/warning)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1080404](/DIQs/DS08/1080404) | Negative or Missing Budget Dollars | Does this WAD have only negative or zero budget dollar values? | budget_labor_dollars <= 0 & budget_labor_hours <= 0 & budget_material_dollars <= 0 & budget_ODC_dollars <= 0 & budget_subcontract_dollars <= 0. |
| [1080413](/DIQs/DS08/1080413) | Initial Authorization Date Missing | Is the initial authorization date missing? | initial_auth_date is blank. |
| [1080427](/DIQs/DS08/1080427) | PM Authorization Missing | Is this WAD missing a PM authorization date? | auth_PM_date is blank. |
| [1080433](/DIQs/DS08/1080433) | POP Start After Initial Auth Date | Is the POP start later than the initial auth date for the latest WAD revision? | pop_start_date > initial_auth_date. |
| [1080434](/DIQs/DS08/1080434) | POP Start Earlier Than Previous Revision | Is the POP start of this WAD revision earlier than the POP start of the prior revision? | pop_start_date < pop_start_date of prior auth_PM_date. |
| [1080439](/DIQs/DS08/1080439) | CA & WP WBS Match | Do the CA & WP WBS IDs match? | WBS_ID = WBS_ID_WP. |
| [9080386](/DIQs/DS08/9080386) | CA Labor Dollars Misaligned With Cost | Are the labor budget dollars for this CA WAD misaligned with what is in cost? | budget_labor_dollars <> SUM(DS03.BCWSi_dollars) where EOC = labor (by WBS_ID_CA). |
| [9080387](/DIQs/DS08/9080387) | WP Labor Dollars Misaligned With Cost | Are the labor budget dollars for this WP/PP WAD misaligned with what is in cost? | budget_labor_dollars <> SUM(DS03.BCWSi_dollars) where EOC = labor (by WBS_ID_WP). |
| [9080388](/DIQs/DS08/9080388) | CA Labor Hours Misaligned With Cost | Are the labor budget hours for this CA WAD misaligned with what is in cost? | budget_labor_hours <> SUM(DS03.BCWSi_hours) where EOC = labor (by WBS_ID_CA). |
| [9080389](/DIQs/DS08/9080389) | WP Labor Hours Misaligned With Cost | Are the labor budget hours for this WP/PP WAD misaligned with what is in cost? | budget_labor_hours <> SUM(DS03.BCWSi_hours) where EOC = labor (by WBS_ID_WP). |
| [9080390](/DIQs/DS08/9080390) | CA Material Dollars Misaligned With Cost | Are the material budget dollars for this CA WAD misaligned with what is in cost? | budget_material_dollars <> SUM(DS03.BCWSi_dollars) where EOC = material (by WBS_ID_CA). |
| [9080391](/DIQs/DS08/9080391) | WP Material Dollars Misaligned With Cost | Are the material budget dollars for this WP WAD misaligned with what is in cost? | budget_material_dollars <> SUM(DS03.BCWSi_dollars) where EOC = material (by WBS_ID_WP). |
| [9080392](/DIQs/DS08/9080392) | CA ODC Dollars Misaligned With Cost | Are the ODC budget dollars for this CA WAD misaligned with what is in cost? | budget_ODC_dollars <> SUM(DS03.BCWSi_dollars) where EOC = ODC (by WBS_ID_CA). |
| [9080393](/DIQs/DS08/9080393) | WP ODC Dollars Misaligned With Cost | Are the ODC budget dollars for this WP/PP WAD misaligned with what is in cost? | budget_ODC_dollars <> SUM(DS03.BCWSi_dollars) where EOC = ODC (by WBS_ID_WP). |
| [9080394](/DIQs/DS08/9080394) | CA Overhead Dollars Misaligned With Cost | Are the overhead budget dollars for this CA WAD misaligned with what is in cost? | budget_overhead_dollars <> SUM(DS03.BCWSi_dollars) where EOC = overhead (by WBS_ID_CA). |
| [9080395](/DIQs/DS08/9080395) | WP Overhead Dollars Misaligned With Cost | Are the overhead budget dollars for this WP/PP WAD misaligned with what is in cost? | budget_overhead_dollars <> SUM(DS03.BCWSi_dollars) where EOC = overhead (by WBS_ID_WP). |
| [9080396](/DIQs/DS08/9080396) | CA Subcontract Dollars Misaligned With Cost | Are the subcontract budget dollars for this CA WAD misaligned with what is in cost? | budget_subcontract_dollars <> SUM(DS03.BCWSi_dollars) where EOC = subcontract (by WBS_ID_CA). |
| [9080397](/DIQs/DS08/9080397) | WP Subcontract Dollars Misaligned With Cost | Are the subcontract budget dollars for this WP/PP WAD misaligned with what is in cost? | budget_subcontract_dollars <> SUM(DS03.BCWSi_dollars) where EOC = subcontract (by WBS_ID_WP). |
| [9080400](/DIQs/DS08/9080400) | SLPP with CAM Authorization | Does this SLPP WAD have a CAM authorization date? | auth_CAM_date found where DS01.type = SLPP (by WBS_ID). |
| [9080401](/DIQs/DS08/9080401) | SLPP or PP WAD with Inappropriate EVT | Is EVT for this SLPP or WP-level WAD something other than K? | EVT <> K for SLPP or PP WAD (by DS01.WBS_ID). |
| [9080406](/DIQs/DS08/9080406) | CAM Authorization Missing | Is a CAM authorization date missing for this non-SLPP WAD? | auth_CAM_date is null / blank where DS01.type <> SLPP (by WBS_ID or WBS_ID_WP). |
| [9080407](/DIQs/DS08/9080407) | CAM Misaligned with WBS Hierarchy (CA) | Is the CAM on this CA WAD misaligned with what is in the WBS hierarchy? | DS08.CAM <> DS01.CAM (by WBS_ID). |
| [9080408](/DIQs/DS08/9080408) | CAM Misaligned with WBS Hierarchy (WP) | Is the CAM on this WP/PP WAD misaligned with what is in the WBS hierarchy? | DS08.CAM <> DS01.CAM (by WBS_ID_WP). |
| [9080409](/DIQs/DS08/9080409) | EVT Misaligned with Cost | Is the EVT for this WP/PP-level WAD misaligned with what is in cost? | EVT <> DS03.EVT (by WBS_ID_WP). |
| [9080414](/DIQs/DS08/9080414) | CA Labor Dollars Missing In Cost | Are the labor budget dollars for this CA WAD missing in cost? | budget_labor_dollars > 0 & DS03.BCWSi_dollars = 0 where EOC = labor (by WBS_ID_CA). |
| [9080415](/DIQs/DS08/9080415) | WP Labor Dollars Missing In Cost | Are the labor budget dollars for this WP/PP WAD missing in cost? | budget_labor_dollars > 0 & DS03.BCWSi_dollars = 0 where EOC = labor (by WBS_ID_WP). |
| [9080416](/DIQs/DS08/9080416) | CA Material Dollars Missing In Cost | Are the material budget dollars for this CA WAD missing in cost? | budget_material_dollars > 0 & DS03.BCWSi_dollars = 0 where EOC = material (by WBS_ID_CA). |
| [9080417](/DIQs/DS08/9080417) | WP Material Dollars Missing In Cost | Are the material budget dollars for this WP/PP WAD missing in cost? | budget_material_dollars > 0 & DS03.BCWSi_dollars = 0 where EOC = material (by WBS_ID_WP). |
| [9080419](/DIQs/DS08/9080419) | CA ODC Dollars Missing In Cost | Are the ODC budget dollars for this CA WAD missing in cost? | budget_ODC_dollars > 0 & DS03.BCWSi_dollars = 0 where EOC = ODC (by WBS_ID_CA). |
| [9080420](/DIQs/DS08/9080420) | WP ODC Dollars Missing In Cost | Are the ODC budget dollars for this WP/PP WAD missing in cost? | budget_ODC_dollars > 0 & DS03.BCWSi_dollars = 0 where EOC = ODC (by WBS_ID_WP). |
| [9080421](/DIQs/DS08/9080421) | CA Overhead Dollars Missing In Cost | Are the overhead budget dollars for this CA WAD missing in cost? | budget_overhead_dollars > 0 & DS03.BCWSi_dollars = 0 where EOC = overhead (by WBS_ID_CA). |
| [9080422](/DIQs/DS08/9080422) | WP Overhead Dollars Missing In Cost | Are the overhead budget dollars for this WP/PP WAD missing in cost? | budget_overhead_dollars > 0 & DS03.BCWSi_dollars = 0 where EOC = overhead (by WBS_ID_WP). |
| [9080423](/DIQs/DS08/9080423) | PM Authorization After Earliest Recorded CA Performance or Actuals | Is the PM authorization date for this Control Account later than the CA' first recorded instance of either actuals or performance? | auth_PM_date > minimum DS03.period_date where ACWPi or BCWPi > 0 (by WBS_ID). |
| [9080424](/DIQs/DS08/9080424) | PM Authorization After Earliest Recorded WP Performance or Actuals | Is the PM authorization date for this Work Package later than the WP' first recorded instance of either actuals or performance? | auth_PM_date > minimum DS03.period_date where ACWPi or BCWPi > 0 (by WBS_ID_WP). |
| [9080425](/DIQs/DS08/9080425) | PM Authorization After CA Actual Start | Is the PM authorization date for this Control Account WAD later than the CA's Actual Start date? | auth_PM_date > DS04.AS_date (by WBS_ID). |
| [9080426](/DIQs/DS08/9080426) | PM Authorization After WP Actual Start | Is the PM authorization date for this Work Package WAD later than the WP's Actual Start date? | auth_PM_date > DS04.AS_date (by WBS_ID_WP). |
| [9080430](/DIQs/DS08/9080430) | POP Finish Before Cost Finish (CA) | Is the POP finish for this Control Account WAD before the last recorded SPAE value in cost? | pop_finish_date < max DS03.period_date where BCWS, BCWP, ACWP, or ETC <> 0 (by CA WBS ID). |
| [9080431](/DIQs/DS08/9080431) | POP Finish Before Baseline Early Finish (CA) | Is the POP finish for this Control Account WAD before the baseline early finish? | pop_finish < DS04.EF_date where schedule_type = BL (by DS08.WBS_ID & DS04.WBS_ID via DS01.WBS_ID & DS01.parent_WBS_ID). |
| [9080432](/DIQs/DS08/9080432) | POP Finish Before Baseline Early Finish (WP) | Is the POP finish for this Work Package WAD before the baseline early finish date? | pop_finish < DS04.EF_date where schedule_type = BL (by DS08.WBS_ID_WP & DS04.WBS_ID_WP). |
| [9080436](/DIQs/DS08/9080436) | CA Subcontract Dollars Missing In Cost | Are the subcontract budget dollars for this CA WAD missing in cost? | budget_subcontract_dollars > 0 & DS03.BCWSi_dollars = 0 where EOC = subcontract (by WBS_ID_CA). |
| [9080437](/DIQs/DS08/9080437) | WP Subcontract Dollars Missing In Cost | Are the subcontract budget dollars for this WP/PP WAD missing in cost? | budget_subcontract_dollars > 0 & DS03.BCWSi_dollars = 0 where EOC = subcontract (by WBS_ID_WP). |
| [9080604](/DIQs/DS08/9080604) | POP Finish After Project Planned Completion Milestone | Is the POP finish later than the planned completion milestone? | pop_finish > DS04.ES_date/EF_date where milestone_level = 170 & schedule_type = BL. |
| [9080607](/DIQs/DS08/9080607) | CA & WP Parent-Child Relationship Differs from WBS Hierarchy | Does the parent-child relationship for these CA & WP WBS IDs differ from what's in the WBS hierarchy? | WBS_ID / WBS_ID_WP combo <> DS01.WBS_ID / parent_WBS_ID combo. |
| [9080608](/DIQs/DS08/9080608) | CA WBS ID Missing in WBS Dictionary | Is this CA WBS ID missing in the WBS dictionary? | WBS_ID not in DS01.WBS_ID list. |
| [9080609](/DIQs/DS08/9080609) | CA / SLPP WAD Mistyped In WBS Dictionary | Is this CA / SLPP WAD type as something other than CA or SLPP in the WBS dictionary? | DS01.type <> CA or SLPP for this WBS_ID. |
| [9080610](/DIQs/DS08/9080610) | WAD Missing In WBS Dictionary | Is this PM-authorized WAD missing in the WBS Dictionary (by either WP WBS ID if it exists, or the CA WBS ID)? | WBS_ID_CA or WBS_ID_WP missing from DS01.WBS_ID list (where DS08.auth_PM_date is populated). |
| [9080611](/DIQs/DS08/9080611) | POP Finish Before Cost Finish (CA) | Is the POP finish for this Control Account before the last recorded SPAE value in cost? | pop_finish_date < max DS03.period_date where BCWS, BCWP, ACWP, or ETC <> 0 (by DS08.WBS_ID & DS03.WBS_ID_CA). |
| [9080612](/DIQs/DS08/9080612) | POP Finish Before Cost Finish (WP) | Is the POP finish for this Work Package WAD before the last recorded SPAE value in cost? | pop_finish_date < max DS03.period_date where BCWS, BCWP, ACWP, or ETC <> 0 (by WP WBS ID). |
| [9080613](/DIQs/DS08/9080613) | POP Start After Cost Start (CA) | Is the POP start for this Control Account WAD after the first recorded SPAE value in cost? | pop_start_date > min DS03.period_date where BCWS, BCWP, ACWP, or ETC <> 0 (by CA WBS ID). |
| [9080614](/DIQs/DS08/9080614) | POP Start After Cost Start (CA) | Is the POP start for this Control Account after the first recorded SPAE value in cost? | pop_start_date > max DS03.period_date where BCWS, BCWP, ACWP, or ETC <> 0 (by DS08.WBS_ID & DS03.WBS_ID_CA). |
| [9080615](/DIQs/DS08/9080615) | POP Start After Cost Start (WP) | Is the POP start for this Work Package WAD after the first recorded SPAE value in cost? | pop_start_date > min DS03.period_date where BCWS, BCWP, ACWP, or ETC <> 0 (by DS08.WBS_ID_WP & DS03.WBS_ID_WP). |
| [9080616](/DIQs/DS08/9080616) | POP Start After Schedule Actual Start (CA) | Is the POP Start for this CA WAD after the schedule actual start? | POP_start_date > DS04.AS_date where schedule_type = FC (compare by DS08.WBS_ID, DS01.WBS_ID, DS01.parent_WBS_ID, & DS04.WBS_ID). |
| [9080618](/DIQs/DS08/9080618) | POP Start After Schedule Forecast Start (CA) | Is the POP Start for this Control Account WAD after the forecast start? | POP_start_date > DS04.ES_date where schedule_type = BL (compare by DS08.WBS_ID, DS01.WBS_ID, DS01.parent_WBS_ID, & DS04.WBS_ID). |
| [9080619](/DIQs/DS08/9080619) | POP Start After Schedule Forecast Start (WP) | Is the POP Start for this Work Package WAD after the schedule forecast start? | POP_start_date > DS04.ES_date where schedule_type = BL (compare by DS08.WBS_ID_WP & DS04.WBS_ID). |
| [9080620](/DIQs/DS08/9080620) | WBS Type WAD | Is this WAD a WBS type WBS element in the WBS dictionary? | WBS_ID or WBS_ID_WP in DS01.WBS_ID list where DS01.type = WBS. |
| [9080622](/DIQs/DS08/9080622) | WP WBS ID Missing in WBS Dictionary | Is this WP WBS ID missing in the WBS dictionary? | WBS_ID_WP not in DS01.WBS_ID list. |
| [9080623](/DIQs/DS08/9080623) | WP WAD Mistyped In WBS Dictionary | Is this WP WAD type as something other than WP or PP in the WBS dictionary? | DS01.type <> WP or PP for this WBS_ID. |
## [ALERT](/DIQs/alert)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1080398](/DIQs/DS08/1080398) | WP/PP EOC Comingled (Dollars) | Does this WP/PP WAD have comingled EOCs? | EOC budget dollars > 0 for at least two non-Overhead EOC types, e.g. budget_labor_dollars <> 0 & budget_material_dollar <> 0. |
| [1080399](/DIQs/DS08/1080399) | EVT on CA-Level WAD | Is there an EVT for this CA-level WAD? | EVT <> blank or NA & WBS_ID_WP <> blank. |
| [1080402](/DIQs/DS08/1080402) | Labor Dollars without Labor Hours | Does this WAD have labor dollars but not labor hours? | budget_labor_dollars > 0 & budget_labor_hours = 0. |
| [1080403](/DIQs/DS08/1080403) | Labor Hours without Labor Dollars | Does this WAD have labor hours but not labor dollars? | budget_labor_hours > 0 & budget_labor_dollars = 0. |
| [1080405](/DIQs/DS08/1080405) | CAM Authorization After PM Authorization | Is the CAM authorization date later than the PM's? | auth_CAM_date > auth_PM_date. |
| [1080410](/DIQs/DS08/1080410) | Missing EVT | Is the EVT missing for this WP/PP-level WAD? | EVT is missing or blank. |
| [1080411](/DIQs/DS08/1080411) | Initial Authorization After PM Authorization | Is the initial authorization date for this WAD after the PM date? | initial_auth_date > auth_PM_date (for earliest WAD revision). |
| [1080412](/DIQs/DS08/1080412) | Inconsistent Initial Authorization Date | Is the initial authorization date consistent across revisions? | initial_auth_date differs across revisions (by WAD_ID). |
| [1080418](/DIQs/DS08/1080418) | Narrative Restates Title | Is the narrative the same as the title? | narrative = title. |
| [1080428](/DIQs/DS08/1080428) | Repeat PM Authorization Date Across Revisions | Do multiple revisions share the same PM authorization date? | auth_PM_date repeated where revisions are not the same (by WBS_ID & WBS_ID_WP). |
| [1080435](/DIQs/DS08/1080435) | POP Start On or After POP Finish | Is the POP start on or after the POP finish? | pop_start_date >= pop_finish_date. |
| [1080438](/DIQs/DS08/1080438) | WPM Authorization Date After CAM Authorization Date | Is the WPM's authorization date later than the CAM's? | auth_WPM_date > auth_CAM_date. |
| [1080440](/DIQs/DS08/1080440) | WPM Missing | Is this WPM name missing on this WAD? | WPM is missing or blank where auth_WPM_date found. |
| [9080429](/DIQs/DS08/9080429) | POP Finish After Project Planned Completion Milestone (FC) | Is the POP finish later than the planned completion milestone in the forecast scheduel? | pop_finish > DS04.ES_date/EF_date where milestone_level = 170 & schedule_type = FC. |
| [9080605](/DIQs/DS08/9080605) | POP Finish Before Forecast Early Finish (CA) | Is the POP finish for this Control Account WAD before the forecast early finish? | pop_finish < DS04.EF_date where schedule_type = FC (by DS08.WBS_ID & DS04.WBS_ID via DS01.WBS_ID & DS01.parent_WBS_ID). |
| [9080606](/DIQs/DS08/9080606) | POP Finish Before Forecast Early Finish (WP) | Is the POP finish for this Work Package WAD before the forecast early finish date? | pop_finish < DS04.EF_date where schedule_type = FC (by DS08.WBS_ID_WP & DS04.WBS_ID_WP). |
| [9080617](/DIQs/DS08/9080617) | POP Start After Schedule Actual Start (WP) | Is the POP start for this Work Package WAD after the actual start in the forecast schedule? | pop_start > DS04.AS_date where schedule_type = FC (by DS08.WBS_ID_WP & DS04.WBS_ID_WP). |
| [9080621](/DIQs/DS08/9080621) | WPM Mismatched With WBS Dictionary | Is the WPM name for this WAD mismatched with what is in the WBS Dictionary? | WPM <> DS01.WPM (by DS08.WBS_ID_WP & DS01.WBS_ID). |
