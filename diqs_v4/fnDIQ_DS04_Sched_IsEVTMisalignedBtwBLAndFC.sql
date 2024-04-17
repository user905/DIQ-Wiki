/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>EVT Misaligned Between BL &amp; FC</title>
  <summary>Is the EVT for this task misaligned between BL &amp; FC schedules?</summary>
  <message>Task EVT is misaligned between BL &amp; FC schedules.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040177</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsEVTMisalignedBtwBLAndFC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Tasks as (
		SELECT schedule_type, task_ID, EVT
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
	), Trips as (
		SELECT F.Task_ID
		FROM Tasks F INNER JOIN Tasks B ON F.task_ID = B.task_ID AND F.EVT <> B.EVT
		WHERE F.schedule_type = 'FC' AND B.schedule_type = 'BL'
	)
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND task_ID IN (SELECT task_ID FROM Trips)
)