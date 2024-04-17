/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS17 WBS EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>EU Justification Missing</title>
  <summary>Is an EU justification missing for why the min dollars equal the likely, the likel equal the max, or the min equal the max?</summary>
  <message>justification_EU is missing or blank &amp; EU_min_dollars = EU_likely_dollars, EU_likely_dollars = EU_max_dollars, or EU_max_dollars = EU_min_dollars.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1170573</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS17_WBS_EU_IsEUJustificationMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS17_WBS_EU
	WHERE 
			upload_ID = @upload_ID
		AND (
				EU_min_dollars = EU_likely_dollars OR 
				EU_likely_dollars = EU_max_dollars OR 
				EU_max_dollars = EU_min_dollars 
		)
		and TRIM(ISNULL(justification_EU,'')) = ''
)