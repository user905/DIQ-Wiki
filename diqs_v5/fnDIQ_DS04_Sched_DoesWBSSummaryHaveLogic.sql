/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WBS Summary Task with Logic</title>
  <summary>Does this WBS Summary task have logic?</summary>
  <message>task_ID where type = WS in DS05.task_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040200</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesWBSSummaryHaveLogic] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		S.*
	FROM
		DS04_schedule S INNER JOIN DS05_schedule_logic L ON S.task_ID = L.task_ID
														AND S.schedule_type = L.schedule_type
														AND ISNULL(S.subproject_ID,'') = ISNULL(L.subproject_ID,'')
	WHERE
			S.upload_ID = @upload_ID
		AND L.upload_ID = @upload_ID
		AND S.type = 'WS'
)