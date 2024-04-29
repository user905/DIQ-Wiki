/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Resource Remaining Units Misaligned with Cost BCWR Hours</title>
  <summary>Are the resource remaining units flowing up to the schedule WBS misaligned with the BCWR hours in cost (by WBS_ID &amp; EOC)?</summary>
  <message>Sum of resource remaining hours rolled up into DS04.WBS_ID do not align with BCWR hours in DS03 (by WBS_ID &amp; EOC).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060298</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreRemUnitsMisalignedWithDS03BCWRHours] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostWBS as (
		SELECT WBS_ID_WP WBS, SUM(BCWSi_hours) - SUM(BCWPi_hours) BCWR
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor' AND ISNULL(is_indirect,'') <> 'Y'
		GROUP BY WBS_ID_WP
	), ScheduleWBS as (
		SELECT S.WBS_ID WBS, SubP, SUM(R.RemUnits) RemUnits
		FROM 
			DS04_schedule S INNER JOIN 
			(
				SELECT task_ID, ISNULL(subproject_ID,'') SubP, SUM(remaining_units) RemUnits 
				FROM DS06_schedule_resources 
				WHERE upload_ID = @upload_ID AND schedule_type = 'FC' AND (EOC = 'Labor' OR type = 'Labor')
				GROUP BY task_ID, ISNULL(subproject_ID,'')
			) R ON S.task_ID = R.task_ID AND ISNULL(S.subproject_ID,'') = SubP
		WHERE	S.upload_ID = @upload_ID 
			AND S.schedule_type = 'FC'
		GROUP BY S.WBS_ID, SubP
	), FlagsByWBS as (
		SELECT S.WBS, S.SubP
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.WBS = S.WBS AND C.BCWR <> S.RemUnits
	), FlagsByTask as (
		SELECT S.task_ID, F.SubP
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS AND ISNULL(S.subproject_ID,'') = F.SubP
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN FlagsByTask F ON R.task_ID = F.task_ID AND ISNULL(R.subproject_ID,'') = F.SubP
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'FC'
		AND (R.EOC = 'Labor' OR R.[type] = 'Labor')
)