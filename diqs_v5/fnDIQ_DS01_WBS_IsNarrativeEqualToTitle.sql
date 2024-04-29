/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Title Equal to Narrative</title>
  <summary>Are the Title and Narrative the same?</summary>
  <message>Narrative is not distinct from the Title (Narrative should be your scope paragraph from your WBS Dictionary)</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010020</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsNarrativeEqualToTitle] (
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
		AND TRIM(Title)=TRIM(Narrative)
		AND Title IS NOT NULL
)