/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Subproject Mismatch with WBS Dictionary</title>
  <summary>Is this subproject ID mismatched with what is in DS01 (WBS)?</summary>
  <message>Subproject_ID does not match with subproject_ID in DS01 (WBS) by WBS.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040212</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsSubprojectIDMismatchedWithDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN DS01_WBS W ON S.WBS_ID = W.WBS_ID
											 AND ISNULL(S.subproject_ID,'') <> ISNULL(W.subproject_ID,'')
	WHERE
			S.upload_id = @upload_ID
		AND W.upload_ID = @upload_ID
)