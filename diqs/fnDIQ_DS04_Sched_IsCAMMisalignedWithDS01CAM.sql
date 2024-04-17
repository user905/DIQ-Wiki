/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>CAM Misaligned with DS01 (WBS)</title>
  <summary>Is the CAM for this task misaligned with what is in DS01 (WBS)?</summary>
  <message>CAM name does not align with CAM in DS01 (WBS).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040148</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsCAMMisalignedWithDS01CAM] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN (SELECT WBS_ID, CAM FROM DS01_WBS WHERE upload_ID = @upload_ID) W ON S.WBS_ID = W.WBS_ID
																									AND S.CAM <> W.CAM
	WHERE
		S.upload_id = @upload_ID
)