/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Incremental CV without Root Cause Narrative (Favorable)</title>
  <summary>Is a root cause narrative missing for this CA where the incremental CV is tripping the favorable dollar threshold?</summary>
  <message>DS03.CVi (|BCWPi - ACWPi|) &gt; |DS07.threshold_cost_inc_dollar_fav| &amp; DS11.narrative_RC_CVi is missing or blank (by DS03.WBS_ID_CA &amp; DS11.WBS_ID).</message>
  <grouping>WBS_ID_CA</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030311</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsCViMissingDS11RCNarrFav] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	With VARs as (
		SELECT WBS_ID 
		FROM DS11_variance
		WHERE upload_ID = @upload_id AND narrative_RC_CVi IS NOT NULL
	), CAsWithoutVARs as (
		SELECT WBS_ID_CA CAWBS, ABS(SUM(isnull(BCWPi_dollars,0)) - SUM(isnull(ACWPi_dollars,0))) CVi
		FROM DS03_cost 
		WHERE upload_ID = @upload_ID
			AND period_date = CPP_status_date
			AND WBS_ID_CA NOT IN (SELECT WBS_ID FROM VARs)
		GROUP BY WBS_ID_CA
	), Threshold as (
		SELECT	ABS(ISNULL(threshold_cost_inc_dollar_fav,0)) AS threshold
		FROM	DS07_IPMR_header 
		WHERE	upload_ID = @upload_id
	)
	SELECT 
		C.*
	FROM
		DS03_cost C	INNER JOIN CAsWithoutVARs CV ON C.WBS_ID_CA = CV.CAWBS
					INNER JOIN Threshold T ON CV.CVi > T.threshold
	WHERE
			upload_ID = @upload_id
		AND period_date = CPP_status_date
)