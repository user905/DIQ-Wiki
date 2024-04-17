/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>CD-4 Early Start or Finish Dates Misaligned Between FC &amp; BL</title>
  <summary>Are the early start or finish dates for the CD-4 milestone misaligned between FC &amp; BL?</summary>
  <message>ES_date or EF_date misaligned for CD-4 in the BL &amp; FC schedules (schedule_type = FC &amp; BL).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040321</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_AreCD4DatesMisalignedBtwFCAndBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with MS190 as (
		SELECT WBS_ID, task_ID, ISNULL(subproject_ID,'') SubP, ES_date, EF_date, schedule_type
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND milestone_level = 190
	),Fails as (
		SELECT F.WBS_ID, F.task_id, F.SubP
		FROM MS190 F INNER JOIN MS190 B ON F.WBS_ID = B.WBS_ID
										AND F.task_ID = B.task_ID
										AND F.SubP = B.SubP
		WHERE
				F.schedule_type = 'FC' 
			AND B.schedule_type = 'BL'
			AND (F.ES_date <> B.ES_date OR F.EF_date <> B.EF_date)
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Fails F ON S.task_ID = F.task_ID AND S.WBS_ID = F.WBS_ID AND ISNULL(S.subproject_ID,'') = F.SubP
	WHERE
		S.upload_ID = @upload_ID
)