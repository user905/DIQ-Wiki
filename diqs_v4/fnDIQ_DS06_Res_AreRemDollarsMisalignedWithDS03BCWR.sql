/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Resource Remaining Dollars Misaligned with Cost BCWR</title>
  <summary>Are the resource remaining dollars flowing up to the schedule WBS misaligned with the BCWR in cost (by WBS_ID &amp; EOC)?</summary>
  <message>Sum of resource remaining dollars rolled up into DS04.WBS_ID do not align with BCWR in DS03 (by WBS_ID &amp; EOC).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060297</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreRemDollarsMisalignedWithDS03BCWR] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostWBS as (
		SELECT WBS_ID_WP WBS, EOC, SUM(BCWSi_dollars) - SUM(BCWPi_dollars) BCWR
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_WP, EOC
	), Resources as (
		SELECT task_ID, EOC, SUM(remaining_dollars) RemDollars 
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC' 
		GROUP BY task_ID, EOC
	), ScheduleWBS as (
		SELECT S.WBS_ID WBS, R.EOC, SUM(R.RemDollars) RemDollars
		FROM DS04_schedule S INNER JOIN Resources R ON S.task_ID = R.task_ID
		WHERE S.upload_ID = @upload_ID AND S.schedule_type = 'FC'
		GROUP BY S.WBS_ID, R.EOC
	), FlagsByWBS as (
		SELECT S.WBS,S.EOC
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.EOC = S.EOC 
												AND C.WBS = S.WBS 
												AND C.BCWR <> S.RemDollars
	), FlagsByTask as (
		SELECT S.task_ID, F.EOC
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN FlagsByTask F 	ON R.task_ID = F.task_ID 
															AND R.EOC = F.EOC
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'FC'
		AND F.EOC = R.EOC
)