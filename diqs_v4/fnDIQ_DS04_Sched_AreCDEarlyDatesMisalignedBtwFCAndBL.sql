/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>DELETED</status>
  <severity>ALERT</severity>
  <title>CD or BCP Early Start or Finish Dates Misaligned Between FC &amp; BL</title>
  <summary>Are the early start or finish dates for this CD/BCP misaligned between FC &amp; BL?</summary>
  <message>ES_date or EF_date do not align for this CD/BCP (milestone_level = 1xx) in the BL &amp; FC schedules (schedule_type = FC &amp; BL).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040108</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_AreCDEarlyDatesMisalignedBtwFCAndBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Fails as (
		SELECT 
			F.WBS_ID, F.task_id
		FROM 
			(SELECT WBS_ID, task_ID, ES_date, EF_date FROM DS04_schedule where upload_ID = @upload_ID AND schedule_type='FC' AND milestone_level BETWEEN 100 AND 199) F,
			(SELECT WBS_ID, task_ID, ES_date, EF_date FROM DS04_schedule where upload_ID = @upload_ID AND schedule_type='BL' AND milestone_level BETWEEN 100 AND 199) B
		WHERE
				F.WBS_ID = B.WBS_ID
			AND F.task_ID = B.task_ID
			AND (F.ES_date <> B.ES_date OR F.EF_date <> B.EF_date)
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