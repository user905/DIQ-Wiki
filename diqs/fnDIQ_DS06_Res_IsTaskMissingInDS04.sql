/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Resource Task Missing in Schedule</title>
  <summary>Is the task this resource is assigned to missing in the schedule?</summary>
  <message>Task_ID missing in DS04.task_ID list (by schedule_type &amp; subproject_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060301</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsTaskMissingInDS04] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Tasks as (
		SELECT schedule_type, task_ID, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
	)
	SELECT R.*
	FROM DS06_schedule_resources R LEFT OUTER JOIN Tasks T ON R.schedule_type = T.schedule_type 
														 	AND R.task_ID = T.task_ID
															AND ISNULL(R.subproject_ID,'') = T.SubP
	WHERE 	R.upload_id = @upload_ID
		AND TRIM(ISNULL(R.task_ID,'')) <> ''
		AND T.task_ID IS NULL
)