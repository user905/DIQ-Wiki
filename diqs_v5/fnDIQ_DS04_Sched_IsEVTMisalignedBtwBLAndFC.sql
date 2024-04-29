/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>EVT Misaligned Between BL &amp; FC</title>
  <summary>Is the EVT for this task misaligned between BL &amp; FC schedules?</summary>
  <message>Task EVT where schedule_type = FC &lt;&gt; EVT where schedule_type = BL.</message>
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
		SELECT schedule_type, task_ID, ISNULL(EVT,'') EVT, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
	), Trips as (
		SELECT F.Task_ID, F.SubP
		FROM Tasks F INNER JOIN Tasks B ON F.task_ID = B.task_ID AND F.SubP = B.SubP AND F.EVT <> B.EVT
		WHERE F.schedule_type = 'FC' AND B.schedule_type = 'BL'
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Trips T ON S.task_ID = T.task_ID AND ISNULL(S.subproject_ID,'') = T.SubP
	WHERE
		upload_id = @upload_ID
)