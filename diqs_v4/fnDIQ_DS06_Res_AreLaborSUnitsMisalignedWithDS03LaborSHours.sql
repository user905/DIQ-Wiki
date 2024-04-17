/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Resource Labor Units Misaligned with Cost</title>
  <summary>Are the labor budget units in resources misaligned with the labor budget hours in cost?</summary>
  <message>Resource labor budget units (budget_units where EOC or type = Labor) &lt;&gt; cost labor DB (SUM of DS03.BCWSi_dollars where EOC = Labor) by WBS_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060291</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreLaborSUnitsMisalignedWithDS03LaborSHours] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostWBS as (
		SELECT WBS_ID_WP WBS, SUM(BCWSi_hours) DB
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor'
		GROUP BY WBS_ID_WP
	), ScheduleWBS as (
		SELECT
			S.WBS_ID WBS,
			SUM(R.budget_units) Budget
		FROM 
			DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID
		WHERE
				S.upload_ID = @upload_ID 
			AND R.upload_ID = @upload_ID
			AND R.schedule_type = 'BL'
			AND S.schedule_type = 'BL'
			AND (R.EOC = 'Labor' OR R.[type] = 'Labor')
		GROUP BY S.WBS_ID
	), FlagsByWBS as (
		SELECT S.WBS
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.WBS = S.WBS AND C.DB <> S.Budget
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
		AND (R.EOC = 'Labor' OR R.[type] = 'Labor')
)