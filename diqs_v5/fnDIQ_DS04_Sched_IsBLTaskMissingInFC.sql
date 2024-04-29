/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Baseline Task Missing In Forecast</title>
  <summary>Is this task missing in the forecast schedule?</summary>
  <message>Task found in baseline schedule (schedule_type = BL) but not in forecast (schedule_type = FC) (by subproject_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040145</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsBLTaskMissingInFC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with FCTasks as (
		SELECT task_ID, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
	)
	SELECT
		B.*
	FROM
		DS04_schedule B LEFT OUTER JOIN FCTasks F ON B.task_ID = F.task_ID AND ISNULL(B.subproject_ID,'') = F.SubP
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'BL' -- Baseline Tasks
		AND F.task_ID IS NULL --Any missed joins fail
)