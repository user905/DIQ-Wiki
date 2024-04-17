/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS05 Schedule Logic</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Predecessor Missing in Schedule</title>
  <summary>Is this predecessor missing in the schedule?</summary>
  <message>predecessor_task_ID not found in DS04 task_ID list (by schedule_type).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9050281</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS05_Logic_IsPredMissingInDS04] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Tasks as (
		SELECT schedule_type, task_ID, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule
		WHERE upload_id = @upload_ID
	)
	SELECT L.*
	FROM DS05_schedule_logic L LEFT OUTER JOIN Tasks T 	ON L.schedule_type = T.schedule_type 
														AND L.predecessor_task_ID = T.task_ID 
														AND ISNULL(L.predecessor_subproject_ID,T.SubP) = T.SubP
	WHERE upload_id = @upload_ID AND T.task_ID IS NULL --any missed join is an error
)