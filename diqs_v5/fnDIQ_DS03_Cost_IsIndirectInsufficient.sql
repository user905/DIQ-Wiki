/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Insufficient Indirect</title>
  <summary>Is this WP or PP lacking sufficient Indirect? (Minimally 10% of the total budget by period)</summary>
  <message>BCWSi_dollars/hours/FTEs for this WP or PP makes up less than 10% of total budget for this period (on Dollars, Hours, or FTEs).</message>
  <grouping>WBS_ID_CA, WBS_ID_WP, period_date</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030094</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsIndirectInsufficient] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with TotalS AS (
		SELECT WBS_ID_CA CAID, WBS_ID_WP WPID, period_date Period, NULLIF(SUM(BCWSi_Dollars),0) D
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_CA, WBS_ID_WP, period_date
	), Indirects AS (
		SELECT WBS_ID_CA CAID, WBS_ID_WP WPID, period_date Period, SUM(BCWSi_Dollars) D
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (EOC = 'Indirect' or is_indirect = 'Y')
		GROUP BY WBS_ID_CA, WBS_ID_WP, period_date
	), Flags AS (
		SELECT T.CAID, T.WPID, T.Period
		FROM TotalS T INNER JOIN Indirects I ON T.CAID = I.CAID 
											AND T.WPID = I.WPID
											AND T.[Period] = I.[Period]
		WHERE ABS(I.D / T.D) < .1 
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