/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS21 Rates</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Indirect Rate Missing Burden</title>
  <summary>Is there a burden ID missing for this indirect rate?</summary>
  <message>type = I &amp; burden_ID is missing or blank.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1210600</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS21_Rates_IsIndirectRateMissingBurden] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS21_rates
	WHERE 
			upload_ID = @upload_ID
		AND type = 'I'
		AND TRIM(ISNULL(burden_ID,'')) = ''
)