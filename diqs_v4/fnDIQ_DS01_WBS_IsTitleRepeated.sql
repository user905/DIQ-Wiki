/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Title Not Unique</title>
  <summary>Does the Title appear more than once across the WBS hierarchy?</summary>
  <message>WBS Title is not unique across the WBS hierarchy.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010030</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsTitleRepeated] (
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
		AND DS01_WBS.Title IN (SELECT Title FROM DS01_WBS WHERE upload_ID = @upload_ID GROUP BY Title HAVING COUNT(Title) > 1)
)