/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>WBS ID Not Unique</title>
  <summary>Is the WBS ID repeated across the WBS hierarchy?</summary>
  <message>WBS ID is not unique across the WBS hierarchy.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010032</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_PK] (
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
		AND DS01_WBS.WBS_ID IN (
			SELECT WBS_ID 
			FROM DS01_WBS 
			WHERE upload_ID = @upload_ID 
			GROUP BY WBS_ID 
			HAVING COUNT(WBS_ID) > 1
		)
)