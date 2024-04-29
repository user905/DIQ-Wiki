/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate Task ID</title>
  <summary>Is this task duplicated in the schedule?</summary>
  <message>Duplicate task ID found (by subproject_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040215</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT task_ID, schedule_type, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
		GROUP BY task_ID, schedule_type, ISNULL(subproject_ID,'')
		HAVING COUNT(*) > 1
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Dupes D 	ON S.task_ID = D.task_ID
											AND S.schedule_type = D.schedule_type
											AND ISNULL(S.subproject_ID,'') = D.SubP
	WHERE
		upload_id = @upload_ID
)