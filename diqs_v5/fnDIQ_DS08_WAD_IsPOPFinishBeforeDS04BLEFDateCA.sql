/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>POP Finish Before Baseline Early Finish (CA)</title>
  <summary>Is the POP finish for this Control Account WAD before the baseline early finish?</summary>
  <message>pop_finish &lt; DS04.EF_date where schedule_type = BL (by DS08.WBS_ID &amp; DS04.WBS_ID via DS01.WBS_ID &amp; DS01.parent_WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080431</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPFinishBeforeDS04BLEFDateCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CAFinish as (
		SELECT A.CAWBS, MAX(S.EF_date) EF
		FROM
			DS04_schedule S INNER JOIN (
				SELECT Ancestor_WBS_ID CAWBS, WBS_ID WPWBS 
				FROM AncestryTree_Get(@upload_ID) 
				WHERE type = 'WP' AND Ancestor_Type = 'CA') A ON S.WBS_ID = A.WPWBS
		WHERE
				S.upload_ID = @upload_ID
			AND S.schedule_type = 'BL'
		GROUP BY A.CAWBS
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W 	INNER JOIN CAFinish C ON W.WBS_ID = C.CAWBS
										  AND W.POP_finish_date <> C.EF
					INNER JOIN LatestCAWADRev_Get(@upload_ID) R ON W.WBS_ID = R.WBS_ID
																AND W.auth_PM_date = R.PMAuth 
	WHERE
			upload_ID = @upload_ID  
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) = ''
)