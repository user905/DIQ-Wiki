/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>External WBS Without Subproject ID</title>
  <summary>Is the external WBS missing a subproject ID?</summary>
  <message>External = Y &amp; subproject_ID is missing or blank.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010019</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsExternalMissingSubprojectID] (
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
		AND [external] = 'Y'
		AND TRIM(ISNULL(subproject_ID, '')) = ''
)