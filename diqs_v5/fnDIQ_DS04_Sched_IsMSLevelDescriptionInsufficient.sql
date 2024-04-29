/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Insufficient Milestone Level Description</title>
  <summary>Is a sufficient milestone level description lacking for this milestone?</summary>
  <message>Milestone is lacking a sufficient milestone level description (at least two words required).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040194</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsMSLevelDescriptionInsufficient] (
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
		AND CHARINDEX(' ',TRIM([milestone_level_description])) = 0
)