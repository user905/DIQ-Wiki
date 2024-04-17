/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS02 OBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Parent OBS ID Missing In OBS List</title>
  <summary>Is the Parent OBS ID missing in the OBS ID list?</summary>
  <message>Parent OBS ID not found in the OBS ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1020050</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS02_OBS_IsParentMissingFromOBSIDList] (
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
    AND [external] = 'N'
		AND parent_OBS_ID NOT IN (SELECT OBS_ID FROM DS02_OBS WHERE upload_ID=@upload_ID)
)