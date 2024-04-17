/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS19 Sched CAL Std</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate Calendar Name</title>
  <summary>Is this calendar name duplicated in the dataset?</summary>
  <message>Count calendar_name &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1190593</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS19_Sched_CAL_Std_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS19_schedule_calendar_std
	WHERE 
			upload_ID = @upload_ID
		AND calendar_name IN (
			SELECT calendar_name
			FROM DS19_schedule_calendar_std
			WHERE upload_ID = @upload_ID
			GROUP BY calendar_name
			HAVING COUNT(*) > 1
		)
)