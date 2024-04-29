/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CAM Misaligned with WBS Hierarchy (CA)</title>
  <summary>Is the CAM on this CA WAD misaligned with what is in the WBS hierarchy?</summary>
  <message>DS08.CAM &lt;&gt; DS01.CAM (by WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080407</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsCAMMisalignedWithDS01CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		W.*
	FROM
		DS08_WAD W 	INNER JOIN LatestCAWADRev_Get(@upload_ID) LWAD ON W.WBS_ID = LWAD.WBS_ID AND W.auth_PM_date = LWAD.PMAuth --get latest CA WAD rev
					INNER JOIN DS01_WBS WBS ON W.WBS_ID = WBS.WBS_ID AND W.CAM <> WBS.CAM --find discrepancy btw WAD CAM & WBS CAM
	WHERE
			W.upload_ID = @upload_ID   
		AND WBS.upload_ID = @upload_ID
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) = ''
)