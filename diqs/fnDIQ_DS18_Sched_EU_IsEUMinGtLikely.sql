/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS18 Sched EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>EU Minimum Days Greater Than Likely</title>
  <summary>Are the EU minimum days greater than the likely days?</summary>
  <message>EU_min_days &gt; EU_likely_days.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1180589</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS18_Sched_EU_IsEUMinGtLikely] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS18_schedule_EU
	WHERE 
			upload_ID = @upload_ID
		AND EU_min_days > EU_likely_days
)