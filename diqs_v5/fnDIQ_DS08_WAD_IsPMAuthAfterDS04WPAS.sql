/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>PM Authorization After WP Actual Start</title>
  <summary>Is the PM authorization date for this Work Package WAD later than the WP's Actual Start date?</summary>
  <message>auth_PM_date &gt; DS04.AS_date (by WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080426</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPMAuthAfterDS04WPAS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with WPActStart as (
		SELECT WBS_ID WBS, MIN(AS_date) ActStart
		FROM
			DS04_schedule S 
		WHERE 
				upload_ID = @upload_ID 
			AND AS_date IS NOT NULL 
			AND schedule_type = 'FC'
			AND WBS_ID IN (
				SELECT WBS_ID
				FROM DS01_WBS
				WHERE upload_ID = @upload_ID AND type = 'WP'
			)
		GROUP BY 
			WBS_ID
	), WADByMinAuth as (
		SELECT WBS_ID_WP WPWBS, MIN(auth_PM_date) PMAuth
		FROM DS08_WAD
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		GROUP BY WBS_ID_WP
	), Composite as (
		SELECT W.WPWBS, W.PMAuth, ActS.ActStart
		FROM WADByMinAuth W INNER JOIN WPActStart ActS ON W.WPWBS = ActS.WBS
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN Composite C 	ON W.WBS_ID_WP = C.WPWBS
											AND W.auth_PM_date = C.PMAuth
											AND W.auth_PM_date > C.ActStart
	WHERE
			upload_ID = @upload_ID  
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) <> ''
)