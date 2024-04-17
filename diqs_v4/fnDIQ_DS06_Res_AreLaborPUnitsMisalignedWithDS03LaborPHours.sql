/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Resource Labor Performance Misaligned with Cost</title>
  <summary>Are the resource labor performance units misaligned with the cost labor performance hours?</summary>
  <message>Resource labor performance units (actual_units where EOC or type = Labor) &lt;&gt; cost labor performance hours (SUM of DS03.BCWPi_dollars where EOC = Labor).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060287</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreLaborPUnitsMisalignedWithDS03LaborPHours] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostWBS as (
		SELECT WBS_ID_WP WBS, SUM(BCWPi_hours) BCWP
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor'
		GROUP BY WBS_ID_WP
	), ScheduleWBS as (
		SELECT
			S.WBS_ID WBS,
			SUM(R.actual_units) Performance
		FROM 
			DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID
		WHERE
				S.upload_ID = @upload_ID 
			AND R.upload_ID = @upload_ID
			AND R.schedule_type = 'FC'
			AND S.schedule_type = 'FC'
			AND (R.EOC = 'Labor' Or R.[type] = 'Labor')
		GROUP BY S.WBS_ID
	), FlagsByWBS as (
		SELECT S.WBS
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.WBS = S.WBS AND C.BCWP <> S.Performance
	), FlagsByTask as (
		SELECT S.task_ID
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN FlagsByTask F ON F.task_ID = R.task_ID
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'FC'
		AND (R.EOC = 'Labor' OR R.[type] = 'Labor')
)