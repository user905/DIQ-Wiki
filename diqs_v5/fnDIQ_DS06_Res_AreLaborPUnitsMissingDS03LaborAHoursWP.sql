/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Resource Labor Performance without Cost Labor Actuals (WP)</title>
  <summary>Are there resource labor performance units recorded without labor actual hours in cost at the WP level?</summary>
  <message>Resource labor performance units &gt; 0 (actual_units where EOC or type = Labor) while cost labor actuals hours = 0 (SUM of DS03.ACWPi_hours where EOC = Labor) by WBS_ID_WP.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060302</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreLaborPUnitsMissingDS03LaborAHoursWP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostWBS as (
		SELECT WBS_ID_WP WBS, SUM(ISNULL(ACWPi_hours,0)) AHours
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor' AND ISNULL(is_indirect,'') <> 'Y' AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		GROUP BY WBS_ID_WP
	), ScheduleWBS as (
		SELECT S.WBS_ID WBS, ISNULL(S.subproject_ID,'') SubP
		FROM DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID 
																 AND ISNULL(S.subproject_ID,'') = ISNULL(R.subproject_ID,'')
		WHERE	S.upload_ID = @upload_ID 
			AND R.upload_ID = @upload_ID
			AND R.schedule_type = 'FC'
			AND S.schedule_type = 'FC'
			AND (R.EOC = 'Labor' Or R.[type] = 'Labor')
		GROUP BY S.WBS_ID, ISNULL(S.subproject_ID,'')
		HAVING SUM(R.actual_units) > 0
	), FlagsByWBS as (
		SELECT S.WBS, SubP
		FROM ScheduleWBS S LEFT OUTER JOIN CostWBS C ON S.WBS = C.WBS
		WHERE C.AHours = 0 OR C.WBS IS NULL
	), FlagsByTask as (
		SELECT S.task_ID, F.SubP
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS AND ISNULL(S.subproject_ID,'') = F.SubP
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
	)
	SELECT R.*
	FROM DS06_schedule_resources R INNER JOIN FlagsByTask F ON R.task_ID = F.task_ID AND ISNULL(R.subproject_ID,'') = F.SubP
	WHERE 	R.upload_id = @upload_ID
		AND R.schedule_type = 'FC'
		AND (R.EOC = 'Labor' OR R.[type] = 'Labor')
		AND NOT EXISTS (
			SELECT 1 
			FROM DS03_cost 
			WHERE upload_ID = @upload_id AND TRIM(ISNULL(WBS_ID_WP,'')) = '' AND (ACWPi_dollars > 0 OR ACWPi_hours > 0 OR ACWPi_FTEs > 0)
		)
)