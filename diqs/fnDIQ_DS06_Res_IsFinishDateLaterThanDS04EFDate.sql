/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Resource Finishing Later Than Task</title>
  <summary>Is this resource scheduled to finish after its parent task?</summary>
  <message>Resource finish (finish_date) &gt; DS04.EF_date (by task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060296</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsFinishDateLaterThanDS04EFDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with BL as (
		SELECT task_ID, ISNULL(subproject_ID,'') SubP, EF_date 
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND schedule_type = 'BL'
	)
	SELECT R.*
	FROM DS06_schedule_resources R INNER JOIN BL B ON R.task_ID = B.task_ID 
												  AND ISNULL(R.subproject_ID,'') = B.SubP 
												  AND R.finish_date > B.EF_date
	WHERE	R.upload_id = @upload_ID
		AND R.schedule_type = 'BL'
)