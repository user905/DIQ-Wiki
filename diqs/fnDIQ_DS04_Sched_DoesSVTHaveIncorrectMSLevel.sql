/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>SVT Not Of Allowed Milestone Type</title>
  <summary>Is this non-milestone task marked as an SVT?</summary>
  <message>Task marked as SVT (subtype = SVT), but is not of the appropriate milestone level (milestone_level = 100-135, 140-175, 190-199, 3xx, or 7xx).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040133</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesSVTHaveIncorrectMSLevel] (
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
			upload_id = @upload_ID
		AND ISNULL(subtype,'') = 'SVT'
		AND NOT (
			milestone_level BETWEEN 100 AND 135 OR 
			milestone_level BETWEEN 140 AND 170 OR
			milestone_level BETWEEN 190 AND 199 OR
			milestone_level BETWEEN 300 AND 399 OR
			milestone_level BETWEEN 700 AND 799
		)
)