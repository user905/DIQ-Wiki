/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>POP Finish Before Cost Finish (CA)</title>
  <summary>Is the POP finish for this Control Account before the last recorded SPAE value in cost?</summary>
  <message>pop_finish_date &lt; max DS03.period_date where BCWS, BCWP, ACWP, or ETC &lt;&gt; 0 (by DS08.WBS_ID &amp; DS03.WBS_ID_CA).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080611</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPFinishBeforeDS03FinishCARollup] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostFinish as (
		SELECT WBS_ID_CA CAWBS, MAX(period_date) Period
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (
			BCWSi_dollars <> 0 OR BCWSi_hours <> 0 OR BCWSi_FTEs <> 0 OR
			BCWPi_dollars <> 0 OR BCWPi_hours <> 0 OR BCWPi_FTEs <> 0 OR
			ACWPi_dollars <> 0 OR ACWPi_hours <> 0 OR ACWPi_FTEs <> 0 OR
			ETCi_dollars <> 0 OR ETCi_hours <> 0 OR ETCi_FTEs <> 0
		)
		GROUP BY WBS_ID_CA
	), CAWADRollup as (
		SELECT W.WBS_ID, MAX(W.auth_PM_date) PMAuth, MAX(POP_finish_date) PFinish
		FROM DS08_WAD W  INNER JOIN LatestWPWADRev_Get(@upload_ID) R ON W.WBS_ID_WP = R.WBS_ID_WP 
																	AND W.auth_PM_date = R.PMAuth
		WHERE upload_ID = @upload_id
		GROUP BY W.WBS_ID
	), Flags as (
		SELECT W.WBS_ID, PMAuth
		FROM CAWADRollup W INNER JOIN CostFinish C ON W.WBS_ID = C.CAWBS
													AND W.PFinish < C.[Period]
	)
	SELECT 
		W.*
	FROM 
		DS08_WAD W INNER JOIN Flags F ON W.WBS_ID = F.WBS_ID
										AND W.auth_PM_date = F.PMAuth
	WHERE 
			upload_ID = @upload_ID
		AND ( -- return only if WADs are at the WP level
			SELECT COUNT(*) 
			FROM DS08_WAD 
			WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		) = 0
)