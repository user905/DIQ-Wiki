/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>WPM Name Matches CAM</title>
  <summary>Is the WPM name the same as the CAM name?</summary>
  <message>WPM name is the same as the CAM name for this WBS</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010010</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_DoesWPMMatchCAM] (
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
		AND WPM = CAM
		AND ISNULL(WPM,'') <> ''
)