/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>WPM Mismatched With WBS Dictionary</title>
  <summary>Is the WPM name for this WAD mismatched with what is in the WBS Dictionary?</summary>
  <message>WPM &lt;&gt; DS01.WPM (by DS08.WBS_ID_WP &amp; DS01.WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080621</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsWPMMismatchedWithDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		W.*
	FROM
		DS08_WAD W 	INNER JOIN LatestWPWADRev_Get(@upload_ID) R ON W.WBS_ID_WP = R.WBS_ID_WP AND W.auth_PM_date = R.PMauth
					INNER JOIN DS01_WBS WBS ON W.WBS_ID_WP = WBS.WBS_ID
	WHERE
			W.upload_ID = @upload_ID
		AND WBS.upload_ID = @upload_ID
		AND R.WBS_ID_WP <> ''
		AND W.WPM <> WBS.WPM
)