/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS12 Variance CAL</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CAL ID Missing in Variance CAL ID List</title>
  <summary>Is this CAL missing in the variance CAL list?</summary>
  <message>CAL_ID not in DS11.CAL_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9120496</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS12_VAR_CAL_IsCALIDMissingInDS11] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM 
		DS12_variance_CAL
	WHERE 
			upload_ID = @upload_ID
		AND CAL_ID NOT IN (
			SELECT CAL_ID
			FROM DS11_variance
			WHERE upload_ID = @upload_ID
		)
)