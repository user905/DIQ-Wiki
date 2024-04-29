/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CAM Misaligned with WBS Hierarchy (WP)</title>
  <summary>Is the CAM on this WP/PP WAD misaligned with what is in the WBS hierarchy?</summary>
  <message>DS08.CAM &lt;&gt; DS01.CAM (by WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080408</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsCAMMisalignedWithDS01WP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		W.*
	FROM
		DS08_WAD W 	INNER JOIN LatestWPWADRev_Get(@upload_ID) LW ON W.WBS_ID_WP = LW.WBS_ID_WP AND W.auth_PM_date = LW.PMAuth
					INNER JOIN DS01_WBS WBS ON W.WBS_ID_WP = WBS.WBS_ID AND W.CAM <> WBS.CAM
	WHERE
			W.upload_ID = @upload_ID   
		AND WBS.upload_ID = @upload_ID
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) <> ''
)