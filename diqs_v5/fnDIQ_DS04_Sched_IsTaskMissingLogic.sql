/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Missing Logic</title>
  <summary>Is this task missing logic?</summary>
  <message>Task_ID missing from DS05.task_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040216</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsTaskMissingLogic] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
    with Logic as (
        SELECT schedule_type, task_ID, subproject_ID
        FROM DS05_schedule_logic
        WHERE upload_ID = @upload_ID
    )
	SELECT
		S.*
	FROM
		DS04_schedule S LEFT OUTER JOIN Logic L ON S.schedule_type = L.schedule_type 
                                                AND S.task_ID = L.task_ID
												AND ISNULL(S.subproject_ID,'') = ISNULL(L.subproject_ID,'')
	WHERE
			S.upload_id = @upload_ID
		AND ISNULL(S.milestone_level,0) <> 100
		AND ISNULL(S.subtype,'') <> 'SVT'
		AND S.type <> 'WS'
		AND L.task_ID IS NULL
)