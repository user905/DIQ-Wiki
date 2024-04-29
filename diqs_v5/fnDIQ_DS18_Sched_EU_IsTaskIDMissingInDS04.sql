/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS18 Sched EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Schedule EU Task Missing in Schedule</title>
  <summary>Is this schedule EU task missing in its respective schedule?</summary>
  <message>task_ID not in DS04.task_ID list (by schedule_type, task_ID, and subproject_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9180591</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS18_Sched_EU_IsTaskIDMissingInDS04] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT E.*
	FROM DS18_schedule_EU E LEFT OUTER JOIN DS04_schedule S ON E.task_ID = S.task_ID 
															AND E.schedule_type = S.schedule_type
															AND ISNULL(E.subproject_ID,'') = ISNULL(S.subproject_ID,'')
	WHERE 
			E.upload_ID = @upload_ID
		AND S.upload_ID = @upload_ID
		AND S.task_ID IS NULL
)