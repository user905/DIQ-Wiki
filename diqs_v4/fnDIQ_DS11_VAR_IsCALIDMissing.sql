/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>CAL ID Missing</title>
  <summary>Is the CAL ID missing for this VAR?</summary>
  <message>CAL_ID is missing or blank.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1110484</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsCALIDMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM 
		DS11_variance
	WHERE 
			upload_ID = @upload_ID
		AND TRIM(ISNULL(CAL_ID,'')) = ''
)