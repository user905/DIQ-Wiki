/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Baseline Task Missing In Forecast</title>
  <summary>Is this task missing in the forecast schedule?</summary>
  <message>Task found in baseline schedule (schedule_type = BL) but not in forecast (schedule_type = FC).</message>
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
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'BL'
		AND task_ID NOT IN (
			SELECT task_ID
			FROM DS04_schedule
			WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
		)
)