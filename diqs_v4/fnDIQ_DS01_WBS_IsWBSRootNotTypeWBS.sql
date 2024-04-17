/*
<documentation>
  <author>Elias Cooper</author>
  <id>9</id>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Root of WBS hierarchy must be of type WBS</title>
  <summary>Is the top element of your WBS hierarchy of a type other than WBS?</summary>
  <message>Level 1 WBS element not of type WBS.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010033</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsWBSRootNotTypeWBS] (
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
		AND [Type]<>'WBS' 
		AND [Level]=1
)