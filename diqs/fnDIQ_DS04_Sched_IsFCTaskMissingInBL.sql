/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Forecast Task Missing In Baseline</title>
  <summary>Is this task missing in the baseline schedule?</summary>
  <message>Task found in forecast schedule (schedule_type = FC) but not in baseline (schedule_type = BL) (by subproject_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040178</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsFCTaskMissingInBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with BLTasks as (
		SELECT task_ID, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND schedule_type = 'BL'
	)
	SELECT
		F.*
	FROM
		DS04_schedule F LEFT OUTER JOIN BLTasks B ON F.task_ID = B.task_ID AND ISNULL(F.subproject_ID,'') = B.SubP
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'FC' -- Forecast Tasks
		AND B.task_ID IS NULL --Any missed joins fail
)