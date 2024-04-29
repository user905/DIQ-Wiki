/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Incremental CV Percent without Root Cause Narrative (Favorable)</title>
  <summary>Is a root cause narrative missing for this CA where the incremental CV percent is tripping the favorable percent threshold?</summary>
  <message>DS03.CVi (|(BCWPi - ACWPi) / BCWPi|) &gt; |DS07.threshold_cost_inc_pct_fav| &amp; DS11.narrative_RC_CVi is missing or blank (by DS03.WBS_ID_CA &amp; DS11.WBS_ID).</message>
  <grouping>WBS_ID_CA, period_date</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030322</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsCViPctMissingDS11RCNarrFav] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with threshold as (
		SELECT ABS(ISNULL(threshold_cost_inc_pct_fav,0)) thrshld
		FROM DS07_IPMR_header 
		WHERE upload_ID = @upload_ID
	), CACV as (
		SELECT 
			WBS_ID_CA CAWBS, 
			ABS((SUM(BCWPi_dollars) - SUM(ACWPi_dollars)) / NULLIF(SUM(BCWPi_dollars),0)) CViPct
		FROM DS03_cost C
		WHERE	upload_ID = @upload_ID
			AND period_date = CPP_status_date
			AND WBS_ID_CA NOT IN (
				SELECT WBS_ID 
				FROM DS11_variance
				WHERE upload_ID = @upload_ID AND narrative_RC_CVi IS NOT NULL
			)
		GROUP BY WBS_ID_CA
	)
	SELECT 
		C.*
	FROM
		DS03_cost C INNER JOIN CACV CV ON C.WBS_ID_CA = CV.CAWBS
	WHERE
			upload_ID = @upload_ID
		AND CV.CViPct > (SELECT TOP 1 thrshld FROM threshold)
		AND period_date = CPP_status_date
)