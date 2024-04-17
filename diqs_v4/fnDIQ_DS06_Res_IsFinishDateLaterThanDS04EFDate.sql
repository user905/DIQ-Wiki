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
	SELECT
		R.*
	FROM
		DS06_schedule_resources R,
		(SELECT task_ID, EF_date FROM DS04_schedule WHERE upload_ID = @upload_ID AND schedule_type = 'BL') S
	WHERE
			R.upload_id = @upload_ID
		AND R.task_ID = S.task_ID
		AND R.schedule_type = 'BL'
		AND R.finish_date > S.EF_date
)