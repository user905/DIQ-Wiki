/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS16 Risk Register Tasks</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Task ID Missing in Baseline Schedule</title>
  <summary>Is this task ID missing in the baseline schedule?</summary>
  <message>task_ID not in DS04.task_ID list where schedule_type = BL.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9160571</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS16_RR_Tasks_IsTaskIDMissingInDS04BL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS16_risk_register_tasks
	WHERE 
			upload_ID = @upload_ID
		AND task_ID NOT IN (
			SELECT task_ID
			FROM DS04_schedule
			WHERE upload_ID = @upload_ID AND schedule_type = 'BL'
		)
)