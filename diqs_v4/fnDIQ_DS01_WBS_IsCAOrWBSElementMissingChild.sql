/*
<documentation>
  <author>Elias Cooper</author>
  <id>13</id>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>CA or WBS Without Child</title>
  <summary>Does the Control Account or WBS Type have a child in the WBS hierarchy?</summary>
  <message>CA or WBS element missing child.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010017</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsCAOrWBSElementMissingChild] (
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
		AND [type] IN ('CA','WBS')
		AND WBS_ID NOT IN (
      SELECT ISNULL(parent_WBS_ID,'')
      FROM DS01_WBS
      WHERE upload_ID = @upload_ID
    )
)