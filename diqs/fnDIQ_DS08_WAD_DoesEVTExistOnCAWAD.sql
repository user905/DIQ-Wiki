/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>EVT on CA-Level WAD</title>
  <summary>Is there an EVT for this CA-level WAD?</summary>
  <message>EVT &lt;&gt; blank or NA &amp; WBS_ID_WP &lt;&gt; blank.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080399</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_DoesEVTExistOnCAWAD] (
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
		AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		AND WBS_ID IN (SELECT WBS_ID FROM DS01_WBS WHERE upload_ID = @upload_ID AND type = 'CA')
		AND ISNULL(EVT,'') NOT IN ('','NA')
)