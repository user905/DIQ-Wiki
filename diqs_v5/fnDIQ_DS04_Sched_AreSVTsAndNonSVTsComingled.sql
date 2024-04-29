/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Comingling of SVT &amp; Non-SVT</title>
  <summary>Does this WBS comingle SVT &amp; Non-SVT tasks?</summary>
  <message>WBS has SVT tasks &amp; Non-SVT tasks (subtype = SVT &amp; subtype &gt;&lt; SVT by WBS_ID).</message>
  <grouping>WBS_ID, schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040114</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_AreSVTsAndNonSVTsComingled] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with NonSVT as (
		SELECT WBS_ID, schedule_type
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND ISNULL(subtype,'') <> 'SVT'
		GROUP BY WBS_ID, schedule_type
	), ToFlag as (
		SELECT S.WBS_ID, S.schedule_type
		FROM 
			DS04_schedule S LEFT JOIN NonSVT N 	ON 	S.schedule_type = N.schedule_type
												AND	S.WBS_ID = N.WBS_ID
		WHERE
				S.upload_ID = @upload_ID
			AND ISNULL(S.subtype,'') = 'SVT'
			AND N.WBS_ID IS NOT NULL
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN ToFlag F ON S.WBS_ID = F.WBS_ID
											AND S.schedule_type = F.schedule_type
	WHERE
		upload_id = @upload_ID
)