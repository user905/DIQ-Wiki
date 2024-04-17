/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Resource Budgets Misaligned with Cost</title>
  <summary>Are the resource budget dollars misaligned with what is in cost?</summary>
  <message>Resource budget_dollars &lt;&gt; cost DB (SUM of DS03.BCWSi_dollars) by WBS_ID &amp; EOC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060290</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreSDollarsMisalignedWithDS03SDollars] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostWBS as (
		SELECT WBS_ID_WP WBS, EOC, SUM(BCWSi_dollars) DB
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_WP, EOC
	), ScheduleWBS as (
		SELECT
			S.WBS_ID WBS,
			R.EOC,
			SUM(R.budget_dollars) Budget
		FROM 
			DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID
		WHERE
				S.upload_ID = @upload_ID 
			AND R.upload_ID = @upload_ID
			AND R.schedule_type = 'BL'
			AND S.schedule_type = 'BL'
		GROUP BY S.WBS_ID, R.EOC
	), FlagsByWBS as (
		SELECT S.WBS, S.EOC
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.WBS = S.WBS 
												AND C.EOC = S.EOC 
												AND C.DB <> S.Budget
	), FlagsByTask as (
		SELECT S.task_ID, F.EOC
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS
		WHERE upload_ID = @upload_ID AND schedule_type = 'BL'
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN FlagsByTask F 	ON R.task_ID = F.task_ID
															AND R.EOC = F.EOC
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'BL'
		AND R.EOC = F.EOC
)