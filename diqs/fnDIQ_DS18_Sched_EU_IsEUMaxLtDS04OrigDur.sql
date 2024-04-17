/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS18 Sched EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>EU Maximum Days Less Than Original Duration</title>
  <summary>Are the EU maximum days for this task less than the original duration?</summary>
  <message>EU_max_days &lt; DS04.duration_original_days by schedule_type, task_ID, and subproject_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9180588</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS18_Sched_EU_IsEUMaxLtDS04OrigDur] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT E.*
	FROM DS18_schedule_EU E INNER JOIN DS04_schedule S 	ON E.task_ID = S.task_ID 
													 	AND E.schedule_type = S.schedule_type
														AND ISNULL(E.subproject_ID,'') = ISNULL(S.subproject_ID,'')
														AND EU_max_days < duration_original_days
	WHERE 
			E.upload_ID = @upload_ID
		AND S.upload_ID = @upload_ID 
)