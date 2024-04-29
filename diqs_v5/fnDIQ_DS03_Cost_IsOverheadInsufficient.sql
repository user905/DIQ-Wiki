/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>Insufficient Overhead</title>
  <summary>Is this SLPP, WP, or PP lacking sufficient Overhead? (Minimally 10% of the total Budget by period)</summary>
  <message>Overhead BCWSi for this SLPP, WP, or PP makes up less than 10% of total budget for this period (on Dollars, Hours, or FTEs).</message>
  <grouping>WBS_ID_CA, WBS_ID_WP, period_date</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030093</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsOverheadInsufficient] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with TotalS AS (
		SELECT 
			WBS_ID_CA CAID, WBS_ID_WP WPID, period_date Period,
			NULLIF(SUM(BCWSi_Dollars),0) D, NULLIF(SUM(BCWSi_hours),0) H, NULLIF(SUM(BCWSi_FTEs),0) F
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_CA, WBS_ID_WP, period_date
	), OvhdS AS (
		SELECT 
			WBS_ID_CA CAID, WBS_ID_WP WPID, period_date Period,
			SUM(BCWSi_Dollars) D, SUM(BCWSi_hours) H, SUM(BCWSi_FTEs) F
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Overhead'
		GROUP BY WBS_ID_CA, WBS_ID_WP, period_date
	), Flags AS (
		SELECT T.CAID, T.WPID, T.Period
		FROM TotalS T INNER JOIN OvhdS O 	ON T.CAID = O.CAID 
											AND T.WPID = O.WPID
											AND T.[Period] = O.[Period]
		WHERE 
			ABS(O.D / T.D) < .1 OR 
			ABS(O.H / T.H) < .1 OR 
			ABS(O.F / T.F) < .1
	)
	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN Flags F ON C.WBS_ID_CA = F.CAID
										AND C.WBS_ID_WP = F.WPID
										AND C.period_date = F.period
	WHERE
			upload_ID = @upload_ID
)