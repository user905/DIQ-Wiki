/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Resource Non-Labor Hours Recorded Alongside Cost Labor Hours</title>
  <summary>Are there non-labor budget hours in resources recorded in the same WBS as labor budget hours in cost?</summary>
  <message>Resource labor budget hours &gt; 0 (Sum of budget_units where type &lt;&gt; Labor and UOM = h) and cost labor DB hours &gt; 0 (Sum of DS03.BCWSi_dollars where EOC = Labor) by WBS_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060292</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_DoNonLaborSHoursExistWithDS03LaborSHours] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostWBS as (
		SELECT WBS_ID_WP WBS
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor'
		GROUP BY WBS_ID_WP
		HAVING SUM(BCWSi_hours) > 0
	), ScheduleWBS as (
		SELECT S.WBS_ID WBS
		FROM DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID
		WHERE
				S.upload_ID = @upload_ID 
			AND R.upload_ID = @upload_ID
			AND R.schedule_type = 'BL'
			AND S.schedule_type = 'BL'
			AND R.[type] <> 'labor'
			AND R.UOM = 'h'
		GROUP BY S.WBS_ID
		HAVING SUM(R.budget_units) > 0
	), FlagsByWBS as (
		SELECT S.WBS
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.WBS = S.WBS
	), FlagsByTask as (
		SELECT S.task_ID
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS
		WHERE upload_ID = @upload_ID AND schedule_type = 'BL'
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN FlagsByTask F ON R.task_ID = F.task_ID
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'BL'
		AND R.[type] <> 'labor'
		AND R.UOM = 'h'
)