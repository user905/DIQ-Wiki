/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS02 OBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>OBS ID Not Unique</title>
  <summary>Is the OBS ID repeated across the OBS hierarchy?</summary>
  <message>OBS ID is not unique across the OBS hierarchy.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1020045</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS02_OBS_PK] (
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
		AND OBS_ID IN (
			SELECT OBS_ID 
			FROM DS02_OBS 
			WHERE upload_ID = @upload_ID 
			GROUP BY OBS_ID 
			HAVING COUNT(OBS_ID) > 1
		)
)