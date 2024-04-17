/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS02 OBS</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Narrative Missing</title>
  <summary>Is the OBS narrative missing?</summary>
  <message>Narrative is missing.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1020043</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS02_OBS_IsNarrativeMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		* 
	FROM 
		DS02_OBS
	WHERE 
			upload_ID = @upload_ID
		AND TRIM(ISNULL(Narrative,''))=''
)