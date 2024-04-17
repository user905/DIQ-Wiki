/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS18 Sched EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Schedule EU Justification Missing</title>
  <summary>Is the EU justification missing to explain why the min EU days equal the likely, the likely equal the max, or the min equal the max?</summary>
  <message>justification_EU is missing or blank &amp; EU_min_days = EU_likely_days, EU_likely_days = EU_max_days, or EU_max_days = EU_min_days.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1180585</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS18_Sched_EU_IsEUJustificationMissing] (
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
		AND (
			EU_min_days = EU_likely_days OR 
			EU_likely_days = EU_max_days OR 
			EU_max_days = EU_min_days) 
		AND TRIM(ISNULL(justification_EU,'')) = ''
)