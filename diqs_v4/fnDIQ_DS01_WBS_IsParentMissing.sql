/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Parent WBS ID Missing</title>
  <summary>Is the Parent WBS ID missing?</summary>
  <message>Parent WBS ID is missing.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010026</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsParentMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		* 
	FROM 
		DS01_WBS
	WHERE 
		upload_ID = @upload_ID 
		AND	[Level]>1 
    AND [external] = 'N'
		AND (TRIM(parent_WBS_ID)='' OR parent_WBS_ID IS NULL)
)