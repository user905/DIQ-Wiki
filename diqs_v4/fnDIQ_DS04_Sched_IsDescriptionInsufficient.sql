/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Insufficient Description</title>
  <summary>Is the task lacking a proper description?</summary>
  <message>Task is lacking at least two words in its description.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040165</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsDescriptionInsufficient] (
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
		AND CHARINDEX(' ',TRIM([description])) = 0
)