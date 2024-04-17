/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS02 OBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Parent OBS ID Missing</title>
  <summary>Is the Parent OBS ID missing?</summary>
  <message>Parent OBS ID is missing.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1020049</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS02_OBS_IsParentMissing] (
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
		AND	[Level]>1 
		AND TRIM(ISNULL(parent_OBS_ID,''))=''
)