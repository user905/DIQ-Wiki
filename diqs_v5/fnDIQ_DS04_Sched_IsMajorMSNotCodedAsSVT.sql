/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Major Milestone Not Coded As SVT</title>
  <summary>Is this major milestone not coded as an SVT?</summary>
  <message>Major milestone not coded as an SVT (subtype = SVT) (Required on milestone_level = 100-135, 140-170, 190-199, 3xx, and 7xx).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040191</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsMajorMSNotCodedAsSVT] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_ID = @upload_ID
		AND (
			milestone_level BETWEEN 100 AND 135 OR
			milestone_level BETWEEN 140 AND 170 OR
			milestone_level BETWEEN 190 AND 199 OR
			milestone_level BETWEEN 300 AND 399 OR
			milestone_level BETWEEN 700 AND 799
		)
		AND ISNULL(subtype,'') <> 'SVT'
)