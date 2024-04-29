/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>CD / BCP Late Start or Finish Dates Misaligned Between FC &amp; BL</title>
  <summary>Are the late start or finish dates for this CD/BCP misaligned between FC &amp; BL?</summary>
  <message>LS_date or LF_date does not align for this CD/BCP (milestone_level = 1xx) in the BL &amp; FC schedules (schedule_type = FC &amp; BL).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040111</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_AreCDLateDatesMisalignedBtwFCAndBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Fails as (
		SELECT 
			F.WBS_ID, F.task_id
		FROM 
			(SELECT WBS_ID, task_ID, LF_date, LS_date FROM DS04_schedule where upload_ID = @upload_ID AND schedule_type='FC' AND milestone_level BETWEEN 100 AND 199) F,
			(SELECT WBS_ID, task_ID, LF_date, LS_date FROM DS04_schedule where upload_ID = @upload_ID AND schedule_type='BL' AND milestone_level BETWEEN 100 AND 199) B
		WHERE
				F.WBS_ID = B.WBS_ID
			AND F.task_ID = B.task_ID
			AND (F.LF_date <> B.LF_date OR F.LS_date <> B.LS_date)
	)
	SELECT
		S.*
	FROM
		DS04_schedule S,
		Fails F
	WHERE
			S.upload_ID = @upload_ID
		AND S.task_ID = F.task_ID
		AND S.WBS_ID = F.WBS_ID
)