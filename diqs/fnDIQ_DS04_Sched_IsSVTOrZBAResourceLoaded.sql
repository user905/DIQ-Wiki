/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Resource Loaded SVT or ZBA</title>
  <summary>Is this SVT or ZBA resource loaded?</summary>
  <message>SVT or ZBA (subtype = SVT or ZBA) task_id found in DS06 task_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040214</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsSVTOrZBAResourceLoaded] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Resources as (
		SELECT schedule_type, task_ID, ISNULL(subproject_ID,'') SubP
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Resources R ON S.schedule_type = R.schedule_type
											  AND S.task_ID = R.task_ID
											  AND ISNULL(S.subproject_ID,'') = R.SubP
	WHERE
			upload_id = @upload_ID
		AND subtype IN ('SVT', 'ZBA')
)