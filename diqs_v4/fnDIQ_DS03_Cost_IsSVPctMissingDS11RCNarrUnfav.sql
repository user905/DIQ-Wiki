/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>SV Percent without Root Cause Narrative (Unfavorable)</title>
  <summary>Is a root cause narrative missing for this CA where the SV percent is tripping the unfavorable percent threshold?</summary>
  <message>DS03.SVc % (|(BCWP - BCWS) / BCWS|) &gt; |DS07.threshold_schedule_cum_pct_unfav| &amp; DS11.narrative_RC_SVc is missing or blank (by DS03.WBS_ID_CA &amp; DS11.WBS_ID).</message>
  <grouping>WBS_ID_CA</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030319</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsSVPctMissingDS11RCNarrUnfav] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with threshold as (
		SELECT ABS(ISNULL(threshold_schedule_cum_pct_Unfav,0)) thrshld
		FROM DS07_IPMR_header 
		WHERE upload_ID = @upload_ID
	), VARs as (
		SELECT WBS_ID 
		FROM DS11_variance
		WHERE upload_ID = @upload_ID AND narrative_RC_SVc IS NOT NULL
	), CASV as (
		SELECT WBS_ID_CA CAWBS, ABS((SUM(BCWPi_dollars) - SUM(BCWSi_dollars)) / NULLIF(SUM(BCWSi_dollars),0)) SV
		FROM DS03_cost C
		WHERE 	upload_ID = @upload_ID
			AND WBS_ID_CA NOT IN (SELECT WBS_ID FROM VARs)
		GROUP BY WBS_ID_CA
	)
	SELECT 
		C.*
	FROM
		DS03_cost C INNER JOIN CASV SV ON C.WBS_ID_CA = SV.CAWBS
	WHERE
			upload_ID = @upload_ID
		AND SV.SV > (SELECT TOP 1 thrshld FROM threshold)
		AND (SELECT COUNT(*) FROM VARs) > 0 --test only if DS11 has records
)