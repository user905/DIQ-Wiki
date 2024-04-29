/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>RPG Without Approve Repgrogramming Milestone</title>
  <summary>Does RPG exist without an an approve repgrogramming milestone?</summary>
  <message>Task designated as RPG (RPG = Y) is either marked as the approve RPG MS (miletone_level = 138) or no such milestone found.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040130</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesRpgExistWithoutAppRpgMS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with RpgMS as (
		SELECT schedule_type
		FROM DS04_schedule 
		WHERE upload_ID=@upload_ID AND milestone_level = 138
	)
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND RPG = 'Y'
		AND schedule_type = 'FC'
		AND (
			milestone_level = 138 OR (SELECT COUNT(*) FROM RpgMS WHERE schedule_type = 'FC') = 0
		)
	UNION
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND RPG = 'Y'
		AND schedule_type = 'BL'
		AND (
			milestone_level = 138 OR (SELECT COUNT(*) FROM RpgMS WHERE schedule_type = 'BL') = 0
		)
)