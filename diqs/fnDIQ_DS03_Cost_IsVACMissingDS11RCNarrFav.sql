/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>VAC without Root Cause Narrative (Favorable)</title>
  <summary>Is a root cause narrative missing for this CA where the VAC is tripping the favorable dollar threshold?</summary>
  <message>|BCWSi_dollars - ACWPi_dollars - ETCi_dollars|) &gt; |DS07.threshold_cost_VAC_dollar_fav| &amp; DS11.narrative_overall is missing or blank where DS11.narrative_type = 120 (by DS03.WBS_ID_CA &amp; DS11.WBS_ID).</message>
  <grouping>WBS_ID_CA</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030320</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsVACMissingDS11RCNarrFav] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with threshold as (
		SELECT ABS(ISNULL(threshold_cost_VAC_dollar_fav,0)) thrshld
		FROM DS07_IPMR_header 
		WHERE upload_ID = @upload_ID
	), CAVAC as (
		SELECT 
			WBS_ID_CA CAWBS, 
			ABS(SUM(BCWSi_dollars) - SUM(ACWPi_dollars) - SUM(ETCi_dollars)) VAC
		FROM 
			DS03_cost C
		WHERE 
				upload_ID = @upload_ID
			AND WBS_ID_CA NOT IN (
				SELECT WBS_ID 
				FROM DS11_variance
				WHERE upload_ID = @upload_ID AND narrative_overall IS NOT NULL AND narrative_type = 120
			)
		GROUP BY WBS_ID_CA
	)
	SELECT 
		C.*
	FROM
		DS03_cost C INNER JOIN CAVAC V ON C.WBS_ID_CA = V.CAWBS
	WHERE
			upload_ID = @upload_ID
		AND V.VAC > (SELECT TOP 1 thrshld FROM threshold)
)