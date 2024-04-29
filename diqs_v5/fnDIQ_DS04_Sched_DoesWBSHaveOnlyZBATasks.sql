/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WBS With Only ZBA Tasks</title>
  <summary>Does this WBS have only ZBA tasks?</summary>
  <message>WBS has no other task subtype other than ZBA (subtype = ZBA).</message>
  <grouping>WBS_ID, schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040135</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesWBSHaveOnlyZBATasks] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with NonZBA as (
		SELECT WBS_ID, schedule_type
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND ISNULL(subtype,'') <> 'ZBA'
		GROUP BY WBS_ID, schedule_type
	), ToFlag as (
		SELECT S.WBS_ID, S.schedule_type
		FROM 
			DS04_schedule S LEFT JOIN NonZBA N 	ON 	S.schedule_type = N.schedule_type
												AND	S.WBS_ID = N.WBS_ID
		WHERE
				S.upload_ID = @upload_ID
			AND ISNULL(S.subtype,'') = 'ZBA'
			AND N.WBS_ID IS NULL
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN ToFlag F ON S.WBS_ID = F.WBS_ID
											AND S.schedule_type = F.schedule_type
	WHERE
			upload_id = @upload_ID
)