/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Incremental SV without Root Cause Narrative (Favorable)</title>
  <summary>Is a root cause narrative missing for this CA where the incremental SV is tripping the favorable dollar threshold?</summary>
  <message>DS03.SVi (|BCWPi - BCWSi|) &gt; |DS07.threshold_schedule_inc_dollar_fav| &amp; DS11.narrative_RC_SVi is missing or blank (by DS03.WBS_ID_CA &amp; DS11.WBS_ID).</message>
  <grouping>WBS_ID_CA</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030325</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsSViMissingDS11RCNarrFav] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with threshold as (
		SELECT ABS(ISNULL(threshold_schedule_inc_dollar_fav,0)) thrshld
		FROM DS07_IPMR_header 
		WHERE upload_ID = @upload_ID
	), CASV as (
		SELECT 
			WBS_ID_CA CAWBS, 
			ABS(SUM(BCWPi_dollars) - SUM(BCWSi_dollars)) SVi
		FROM DS03_cost C
		WHERE	upload_ID = @upload_ID
			AND period_date = CPP_status_date
			AND WBS_ID_CA NOT IN (
				SELECT WBS_ID 
				FROM DS11_variance
				WHERE upload_ID = @upload_ID AND narrative_RC_SVi IS NOT NULL
			)
		GROUP BY WBS_ID_CA
	)
	SELECT 
		C.*
	FROM
		DS03_cost C INNER JOIN CASV SV 	ON C.WBS_ID_CA = SV.CAWBS
	WHERE
			upload_ID = @upload_ID
		AND SV.SVi > (SELECT TOP 1 thrshld FROM threshold)
		AND period_date = CPP_status_date
)