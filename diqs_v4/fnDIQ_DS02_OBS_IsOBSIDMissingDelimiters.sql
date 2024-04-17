/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS02 OBS</table>
  <status>DELETED</status>
  <severity>ALERT</severity>
  <title>OBS ID Missing Delimiters</title>
  <summary>Is the OBS ID missing delimiters?</summary>
  <message>OBS ID is missing delimiters (periods recommended).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS02_OBS_IsOBSIDMissingDelimiters] (
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
		AND OBS_ID NOT LIKE '%.%'
)