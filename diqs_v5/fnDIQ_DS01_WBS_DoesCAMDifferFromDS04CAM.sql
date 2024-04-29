/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Different CAM Name from DS04</title>
  <summary>Does the CAM name for this WBS differ from what is in DS04?</summary>
  <message>CAM name differs between DS01 and DS04.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9010004</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_DoesCAMDifferFromDS04CAM] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Sched as (
		SELECT WBS_ID, CASE WHEN Min(ISNULL(CAM,'')) <> MAX(ISNULL(CAM,'')) Then '$' ELSE MIN(ISNULL(CAM,'')) END as 'CAM'
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID
	)
	SELECT 
		W.*
	FROM
		DS01_WBS W INNER JOIN Sched S on W.WBS_ID = S.WBS_ID
	WHERE
			W.upload_ID = @upload_ID
		AND ISNULL(W.CAM,'') <> S.CAM
)