/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>POP Start After Cost Start (CA)</title>
  <summary>Is the POP start for this Control Account WAD after the first recorded SPAE value in cost?</summary>
  <message>pop_start_date &gt; min DS03.period_date where BCWS, BCWP, ACWP, or ETC &lt;&gt; 0 (by CA WBS ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080613</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPStartAfterDS03StartCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostStart as (
		SELECT WBS_ID_CA CAWBS, MIN(period_date) Period
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (
			BCWSi_dollars <> 0 OR BCWSi_hours <> 0 OR BCWSi_FTEs <> 0 OR
			BCWPi_dollars <> 0 OR BCWPi_hours <> 0 OR BCWPi_FTEs <> 0 OR
			ACWPi_dollars <> 0 OR ACWPi_hours <> 0 OR ACWPi_FTEs <> 0 OR
			ETCi_dollars <> 0 OR ETCi_hours <> 0 OR ETCi_FTEs <> 0
		)
		GROUP BY WBS_ID_CA
	)
	SELECT 
		W.*
	FROM 
		DS08_WAD W 	INNER JOIN LatestCAWADRev_Get(@upload_ID) R ON W.WBS_ID = R.WBS_ID 
																AND W.auth_PM_date = R.PMAuth
					INNER JOIN CostStart C 	ON W.WBS_ID = C.CAWBS 
											AND POP_start_date > C.[Period]
	WHERE 
			upload_ID = @upload_ID
		AND TRIM(ISNULL(WBS_ID_WP,'')) = '' -- exclude all WP/PP level WADs
)