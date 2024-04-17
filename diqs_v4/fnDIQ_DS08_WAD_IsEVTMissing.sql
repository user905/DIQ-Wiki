/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Missing EVT</title>
  <summary>Is the EVT missing for this WP/PP-level WAD?</summary>
  <message>EVT is missing or blank.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080410</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsEVTMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS08_WAD
	WHERE
			upload_ID = @upload_ID   
		AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		AND TRIM(ISNULL(EVT,'')) = ''
)