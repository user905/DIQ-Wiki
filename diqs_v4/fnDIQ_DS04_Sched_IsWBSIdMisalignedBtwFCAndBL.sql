/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>WBS Misaligned Between FC &amp; BL</title>
  <summary>Is the WBS ID for this task misaligned between the FC &amp; BL schedules?</summary>
  <message>WBS_ID does not align between the FC &amp; BL schedules for this task_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040220</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsWBSIdMisalignedBtwFCAndBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Tasks as (
		SELECT schedule_type, WBS_ID, task_ID 
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID
	), Flags as (
		SELECT F.task_ID
		FROM Tasks F INNER JOIN Tasks B ON F.task_ID = B.task_ID AND F.WBS_ID <> B.WBS_ID
		WHERE F.schedule_type = 'FC' AND B.schedule_type = 'BL'
	)
	SELECT
		*
	FROM
		DS04_schedule 
	WHERE
			upload_id = @upload_ID
		AND task_ID IN (SELECT task_ID FROM Flags)
)