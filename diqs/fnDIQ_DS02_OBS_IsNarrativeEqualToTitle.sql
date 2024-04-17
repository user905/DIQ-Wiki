/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS02 OBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Title Equal to Narrative</title>
  <summary>Are the Title and Narrative the same?</summary>
  <message>Narrative is not distinct from the Title</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1020042</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS02_OBS_IsNarrativeEqualToTitle] (
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
		AND TRIM(Title)=TRIM(Narrative)
		AND Title IS NOT NULL
)