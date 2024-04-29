/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>SVT With Logic</title>
  <summary>Does this SVT have logic?</summary>
  <message>SVT (subtype = SVT) task_id found in DS05 task_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040134</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesSVTHaveLogic] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Logic as (
		SELECT schedule_type, task_ID, ISNULL(subproject_ID,'') SubP
		FROM DS05_schedule_logic 
		WHERE upload_ID = @upload_ID
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Logic L 	ON S.schedule_type = L.schedule_type
											AND S.task_ID = L.task_ID
											AND ISNULL(S.subproject_ID,'') = L.SubP
	WHERE
			upload_id = @upload_ID
		AND subtype = 'SVT'
)