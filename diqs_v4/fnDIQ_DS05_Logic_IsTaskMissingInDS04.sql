/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS05 Schedule Logic</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Task Missing in Schedule</title>
  <summary>Is this task missing in the schedule?</summary>
  <message>task_ID not found in DS04 task_ID list (by schedule_type).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9050282</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS05_Logic_IsTaskMissingInDS04] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Tasks as (
		SELECT schedule_type, task_ID
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
	)
	SELECT
		*
	FROM
		DS05_schedule_logic
	WHERE
			upload_id = @upload_ID
		AND (
				schedule_type = 'FC' and task_ID NOT IN (SELECT task_ID FROM Tasks WHERE schedule_type = 'FC')
			OR schedule_type = 'BL' and task_ID NOT IN (SELECT task_ID FROM Tasks WHERE schedule_type = 'BL')
		)
)