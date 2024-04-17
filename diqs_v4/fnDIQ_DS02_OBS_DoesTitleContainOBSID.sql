/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS02 OBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Title Contains OBS ID</title>
  <summary>Does the Title contain the OBS ID?</summary>
  <message>OBS ID found within OBS Title.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1020040</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS02_OBS_DoesTitleContainOBSID] (
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
		AND Title like '%' + OBS_ID + '%'
)