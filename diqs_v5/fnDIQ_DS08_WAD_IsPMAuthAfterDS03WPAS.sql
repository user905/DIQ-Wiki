/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>PM Authorization After Earliest Recorded WP Performance or Actuals</title>
  <summary>Is the PM authorization date for this Work Package later than the WP' first recorded instance of either actuals or performance?</summary>
  <message>auth_PM_date &gt; minimum DS03.period_date where ACWPi or BCWPi &gt; 0 (by WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080424</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPMAuthAfterDS03WPAS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with WPActStart as (
		SELECT WBS_ID_CA CAWBS, WBS_ID_WP WPWBS, MIN(period_date) ActStart
		FROM DS03_cost
		WHERE 
				upload_ID = @upload_ID 
			AND (
				ACWPi_dollars <> 0 OR ACWPi_dollars <> 0 OR ACWPi_hours <> 0 OR
				BCWPi_dollars <> 0 OR BCWPi_dollars <> 0 OR BCWPi_hours <> 0
			)
		GROUP BY WBS_ID_CA, WBS_ID_WP
	), WADByMinAuth as (
		SELECT WBS_ID CAWBS, WBS_ID_WP WPWBS, MIN(auth_PM_date) PMAuth
		FROM DS08_WAD
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		GROUP BY WBS_ID, WBS_ID_WP
	), Composite as (
		SELECT W.CAWBS, W.WPWBS, W.PMAuth, C.ActStart
		FROM WADByMinAuth W INNER JOIN WPActStart C ON W.CAWBS = C.CAWBS AND W.WPWBS = C.WPWBS
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN Composite C 	ON W.WBS_ID = C.CAWBS 
											AND W.WBS_ID_WP = C.WPWBS
											AND W.auth_PM_date > C.ActStart
	WHERE
			upload_ID = @upload_ID  
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) <> ''
)