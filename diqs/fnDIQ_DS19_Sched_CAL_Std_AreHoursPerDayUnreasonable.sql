/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS19 Sched CAL Std</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Hours Per Day Less Than Zero Or Greater Than 24</title>
  <summary>Are the hours per day negative or greater than 24?</summary>
  <message>hours_per_day &lt; 0 or hours_per_day &gt; 24.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1190592</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS19_Sched_CAL_Std_AreHoursPerDayUnreasonable] (
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
		AND (hours_per_day < 0 OR hours_per_day > 24)
)