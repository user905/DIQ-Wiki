/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Cost Labor Actuals without Resource Labor Performance</title>
  <summary>Are there labor actual hours in cost without labor performance units in resources?</summary>
  <message>Resource labor performance units = 0 (actual_units where EOC or type = Labor) while cost labor actuals hours &gt; 0 (SUM of DS03.ACWPi_hours where EOC = Labor).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060289</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreDS03LaborAHoursMissingResourceLaborPUnits] (
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
		HAVING SUM(ACWPi_hours) > 0
	), Resources as (
		SELECT task_ID, SUM(ISNULL(actual_units,0)) ResLbrUnits
		FROM DS06_schedule_resources
		WHERE upload_ID = @upload_id AND schedule_type = 'FC' AND (EOC = 'Labor' Or [type] = 'Labor')
		GROUP BY task_ID
	), ScheduleWBS as (
		SELECT S.WBS_ID WBS
		FROM DS04_schedule S LEFT OUTER JOIN Resources R ON S.task_ID = R.task_ID
		WHERE S.upload_ID = @upload_id AND S.schedule_type = 'FC' AND (ResLbrUnits = 0 OR R.task_ID IS NULL)
		GROUP BY S.WBS_ID
	), FlagsByWBS as (
		SELECT S.WBS
		FROM ScheduleWBS S INNER JOIN CostWBS C ON C.WBS = S.WBS
	), FlagsByTaskID as (
		SELECT S.task_ID
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN FlagsByTaskID F ON R.task_ID = F.task_ID
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'FC'
		AND (R.EOC = 'Labor' OR R.[type] = 'Labor')
)