/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WPM Name Found on WBS, CA, or SLPP</title>
  <summary>Is the WPM name attached to a WBS, CA, or SLPP?</summary>
  <message>WPM name found for WBS, CA, or SLPP (WP or PP only)</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010035</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsWPMFoundOnNonPPorWP] (
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
		AND ISNULL(WPM,'') <> ''
		AND type NOT IN ('WP','PP')
)