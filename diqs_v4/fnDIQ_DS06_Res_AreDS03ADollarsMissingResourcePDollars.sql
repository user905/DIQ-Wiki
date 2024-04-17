/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Cost Actuals without Resource Performance</title>
  <summary>Are there actuals in cost without performance in resources (by EOC)?</summary>
  <message>Resource performance (actual_dollars) = 0 even though DS03.ACWPc &gt; 0 (SUM of ACWSi_dollars) by EOC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060285</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreDS03ADollarsMissingResourcePDollars] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostWBS as (
		SELECT WBS_ID_WP WBS, EOC, SUM(ACWPi_dollars) ACWP
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_WP, EOC
		HAVING SUM(ACWPi_dollars) > 0
	), Resources as (
		SELECT task_ID, EOC, SUM(ISNULL(actual_dollars,0)) Performance 
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC' 
		GROUP BY task_ID, EOC
		HAVING SUM(ISNULL(actual_dollars,0)) = 0
	), ScheduleWBS as (
		SELECT S.WBS_ID WBS, R.EOC
		FROM DS04_schedule S INNER JOIN Resources R ON S.task_ID = R.task_ID
		WHERE S.upload_ID = @upload_ID AND S.schedule_type = 'FC'
		GROUP BY S.WBS_ID, R.EOC
	), FlagsByWBS as (
		SELECT S.WBS,S.EOC
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.EOC = S.EOC AND C.WBS = S.WBS
	), FlagsByTaskID as (
		SELECT S.task_ID, F.EOC
		FROM FlagsByWBS F INNER JOIN DS04_schedule S ON F.WBS = S.WBS_ID
		WHERE S.upload_ID = @upload_ID AND S.schedule_type = 'FC'
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN FlagsByTaskID F ON R.task_ID = F.task_ID
															AND R.EOC = F.EOC
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'FC'
)