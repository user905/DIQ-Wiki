## [ERROR](/DIQs/error)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1110495](/DIQs/DS11/1110495) | Duplicate VAR | Is this VAR duplicated by WBS ID & Narrative type? | Count of WBS_ID & narrative_type combo > 1. |
## [WARNING](/DIQs/warning)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1110480](/DIQs/DS11/1110480) | Project-Level VAR With Root Cause Narrative | Does this project-level VAR have a root cause narrative? | narrative_type < 200 & narrative_RC_SVi, narrative_RC_SVc, narrative_RC_CVi, or narrative_RC_CVc. |
| [1110488](/DIQs/DS11/1110488) | Narrative Type Missing | Is the narrative type missing? | narrative_type missing or blank. |
| [1110491](/DIQs/DS11/1110491) | Project-Level VAR Without Overall Narrative | Is this project-level VAR missing an overall narrative? | narrative_type < 200 & narrative_overall is missing or blank. |
| [1110494](/DIQs/DS11/1110494) | Root Cause And/Or Impact Narrative Missing | Is this VAR missing either a root cause or an impact narrative (or both)? | VAR is missing either a RC SV or CV narrative or an impact narrative (or both). |
| [9110482](/DIQs/DS11/9110482) | Approved Date After CAL Dates | Is the approved date for this variance later than the dates for the corrective action date? | approved_date > DS12.initial_date, DS12.original_due_date, DS12.forecast_due_date, or DS12.closed_date (by CAL_ID). |
| [9110485](/DIQs/DS11/9110485) | CAL ID Missing in Corrective Action Log | Is the CAL ID missing in the Corrective Action Log? | CAL_ID missing in DS12.CAL_ID list. |
| [9110486](/DIQs/DS11/9110486) | CA-Level VAR Mistype In WBS Dictionary | Is this CA-level VAR type as something other than CA in the WBS Dictionary? | narrative_type = 300 & DS01.type <> CA (by WBS_ID). |
| [9110489](/DIQs/DS11/9110489) | PP-Level VAR Mistype In WBS Dictionary | Is this PP-level VAR type as something other than PP in the WBS Dictionary? | narrative_type = 400 & DS01.type <> PP (by WBS_ID). |
| [9110490](/DIQs/DS11/9110490) | Project-Level VAR Misaligned With Project-Level WBS | Is this project-level VAR not at Level 1 in the WBS Hierarchy? | narrative_type < 200 & DS01.level > 1 (by WBS_ID). |
| [9110492](/DIQs/DS11/9110492) | SLPP-Level VAR Mistype In WBS Dictionary | Is this SLPP-level VAR type as something other than SLPP in the WBS Dictionary? | narrative_type = 200 & DS01.type <> SLPP (by WBS_ID). |
| [9110494](/DIQs/DS11/9110494) | WBS ID Missing In WBS Hierarchy | Is the WBS ID for this VAR missing in the WBS Hierarchy? | WBS_ID not in DS01.WBS_ID list. |
| [9110495](/DIQs/DS11/9110495) | WP-Level VAR Mistype In WBS Dictionary | Is this WP-level VAR type as something other than WP in the WBS Dictionary? | narrative_type = 500 & DS01.type <> WP (by WBS_ID). |
## [ALERT](/DIQs/alert)

| UID | Title | Summary | Error Message |
|-----|-------|---------|---------------|
| [1110481](/DIQs/DS11/1110481) | SLPP or PP VAR With Root Cause Narrative | Is there a root cause SV or CV narrative for this SLPP or PP VAR? | narrative_type = 200 or 400 & narrative_RC_SVi, narrative_RC_SVc, narrative_RC_CVi, or narrative_RC_CVc. |
| [1110484](/DIQs/DS11/1110484) | CAL ID Missing | Is the CAL ID missing for this VAR? | CAL_ID is missing or blank. |
| [1110487](/DIQs/DS11/1110487) | Cost Variance Root Cause Narrative Missing Impact | Is there a cost variance root cause narrative without an impact statement? | narrative_RC_CVi or narrative_RC_CVc found but narrative_impact_cost is blank or missing. |
| [1110493](/DIQs/DS11/1110493) | Schedule Variance Root Cause Narrative Missing Impact | Is there a schedule variance root cause narrative without an impact statement? | narrative_RC_SVi or narrative_RC_SVc found but narrative_impact_schedule is blank or missing. |
| [9110483](/DIQs/DS11/9110483) | Approved Date Outside Current Period | Is the approved date before the last or after the current status date? | approved_date < DS00.CPP_Status_Date - 1 & approved_date > DS00.CPP_Status_Date. |
| [9110496](/DIQs/DS11/9110496) | CV Root Cause Narrative Missing CAL Cost Narrative | Is this CVi or CVc VAR narrative missing a corrective action log entry with a cost narrative? | narrative_RC_CVc or narrative_RC_CVi found without DS12.narrative_cost (by CAL_ID). |
| [9110497](/DIQs/DS11/9110497) | SV Root Cause Narrative Missing CAL Schedule Narrative | Is this SVi or SVc VAR narrative missing a corrective action log entry with a schedule narrative? | narrative_RC_SVc or narrative_RC_SVi found without DS12.narrative_schedule (by CAL_ID). |
