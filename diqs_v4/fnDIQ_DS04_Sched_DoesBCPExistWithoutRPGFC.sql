/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>BCP Milestones Without Reprogramming</title>
  <summary>Has a BCP occurred without reprogramming tasks? (FC)</summary>
  <message>BCP milestone(s) found (milestone_level = 131 - 135) without accompanying RPG tasks (RPG = Y). (FC)</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040228</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesBCPExistWithoutRPGFC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with BCPCount as (
		SELECT COUNT(*) BCPcnt
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND milestone_level BETWEEN 131 AND 135 AND schedule_type = 'FC'
	), RPGCount as (
		SELECT COUNT(*) RPGcnt
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND RPG = 'Y' AND schedule_type = 'FC'
	)
	SELECT
		*
	FROM
		DummyRow_Get(@upload_ID)
	WHERE
			(SELECT TOP 1 BCPcnt FROM BCPCount) > 0 
		AND (SELECT TOP 1 RPGcnt FROM RPGCount) = 0
)