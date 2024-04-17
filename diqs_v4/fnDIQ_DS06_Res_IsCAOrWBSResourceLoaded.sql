/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Resource Loaded CA or WBS</title>
  <summary>Is this WBS of type CA or WBS resource loaded?</summary>
  <message>WBS ID of type CA or WBS (DS01.type = CA or WBS) found with resources (task_ID found in DS06.task_ID list).</message>
  <grouping>task_ID,schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060283</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsCAOrWBSResourceLoaded] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Task as (
		SELECT WBS_ID, task_ID, schedule_type 
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID
	), WBS as (
		SELECT WBS_ID 
		FROM DS01_WBS 
		WHERE upload_ID = @upload_ID AND type IN ('CA','WBS')
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R 	INNER JOIN Task T ON R.task_ID = T.task_ID AND R.schedule_type = T.schedule_type
									INNER JOIN WBS W ON T.WBS_ID = W.WBS_ID
	WHERE
		upload_id = @upload_ID
)