/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS02 OBS</table>
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>OBS ID with Adjacent Letters</title>
  <summary>Does the OBS ID contain letters side by side?</summary>
  <message>OBS ID contains letters adjacent to one another.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS02_OBS_DoesOBSIDContainAdjacentLetters] (
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
		AND OBS_ID LIKE '[A-Z][A-Z]' 
)