/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>EOC Combo Misaligned with Cost</title>
  <summary>Is the combo of resource EOCs for this task/WBS misaligned with what is in cost?</summary>
  <message>Combo of resource EOCs for this DS04.task's WBS ID do not align with combo of DS03 EOCs.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060294</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsEOCComboMisalignedWithDS03] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostEOCs as (
		SELECT C.WBS, STRING_AGG (C.EOC, ',') WITHIN GROUP (ORDER BY C.EOC) AS EOC
		FROM (
			SELECT WBS_ID_WP WBS, EOC
			FROM DS03_cost
			WHERE upload_ID = @upload_ID
			GROUP BY WBS_ID_WP, EOC
		) C
		GROUP BY C.WBS
	), ScheduleEOCs as (
		SELECT S.WBS, STRING_AGG (S.EOC, ',') WITHIN GROUP (ORDER BY S.EOC) AS EOC
		FROM (
			SELECT S.WBS_ID WBS, R.EOC
			FROM DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID
			WHERE 
					S.upload_ID = @upload_ID 
				AND R.upload_ID = @upload_ID
				AND R.schedule_type = 'BL'
				AND S.schedule_type = 'BL'
			GROUP BY S.WBS_ID, R.EOC
		) S
		GROUP BY S.WBS
	), FlagsByWBS as (
		SELECT S.WBS
		FROM ScheduleEOCs S INNER JOIN CostEOCs C ON S.WBS = C.WBS AND S.EOC <> C.EOC
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
)