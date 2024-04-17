/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Duplicate Description</title>
  <summary>Is the description for this task duplicated?</summary>
  <message>Desription is repeated across task IDs (task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040164</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsDescriptionDuplicated] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with ToFlag As (
		SELECT schedule_type, description
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
		GROUP BY schedule_type, [description]
		HAVING COUNT(*) > 1
	)
	SELECT 
		S.*
	FROM
		DS04_schedule S INNER JOIN ToFlag F ON S.schedule_type = F.schedule_type
											AND S.[description] = F.[description]
	WHERE
		upload_ID = @upload_ID
)