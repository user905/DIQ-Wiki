/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CV without Root Cause Narrative (Unfavorable)</title>
  <summary>Is a root cause narrative missing for this CA where the CV is tripping the unfavorable dollar threshold?</summary>
  <message>DS03.CVc (|BCWP - ACWP|) &gt; |DS07.threshold_cost_cum_dollar_unfav| &amp; DS11.narrative_RC_CVc is missing or blank (by DS03.WBS_ID_CA &amp; DS11.WBS_ID).</message>
  <grouping>WBS_ID_CA</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030313</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsCVMissingDS11RCNarrUnfav] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with threshold as (
		SELECT ABS(ISNULL(threshold_cost_cum_dollar_unfav,0)) thrshld
		FROM DS07_IPMR_header 
		WHERE upload_ID = @upload_ID
	), CACV as (
		SELECT WBS_ID_CA CAWBS, ABS(SUM(BCWPi_dollars) - SUM(ACWPi_dollars)) CV
		FROM DS03_cost C
		WHERE 	upload_ID = @upload_ID
			AND WBS_ID_CA NOT IN (
				SELECT WBS_ID 
				FROM DS11_variance
				WHERE upload_ID = @upload_ID AND narrative_RC_CVc IS NOT NULL
			)
		GROUP BY WBS_ID_CA
	)
	SELECT 
		C.*
	FROM
		DS03_cost C INNER JOIN CACV CV ON C.WBS_ID_CA = CV.CAWBS
	WHERE
			upload_ID = @upload_ID
		AND CV.CV > (SELECT TOP 1 thrshld FROM threshold)
)