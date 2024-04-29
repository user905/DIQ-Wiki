/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS02 OBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Title Not Unique</title>
  <summary>Does the Title appear more than once across the OBS hierarchy?</summary>
  <message>OBS Title is not unique across the OBS hierarchy.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1020052</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS02_OBS_IsTitleRepeated] (
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
		AND DS02_OBS.Title IN (SELECT Title FROM DS02_OBS WHERE upload_ID = @upload_ID GROUP BY Title HAVING COUNT(Title) > 1)
)