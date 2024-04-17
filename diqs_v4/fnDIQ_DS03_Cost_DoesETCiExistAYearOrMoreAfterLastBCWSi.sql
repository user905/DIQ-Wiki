/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Estimates Found A Year or More After Last Recorded Budget</title>
  <summary>Does this WP or PP show estimates a year or more after the last recorded period of budget?</summary>
  <message>Last period_date where ETCi &lt;&gt; 0 is twelve or more months after last period_date of BCWSi &lt;&gt; 0 (on Dollars, Hours, or FTEs).</message>
  <grouping>WBS_ID_CA,WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030066</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesETCiExistAYearOrMoreAfterLastBCWSi] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with LastS as (
		SELECT WBS_ID_WP, MAX(period_date) LastS 
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (BCWSi_dollars > 0 OR BCWSi_hours > 0 OR BCWSi_FTEs > 0)
		GROUP BY WBS_ID_WP
	), EPeriod as (
		SELECT WBS_ID_WP, period_date EPeriod
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (ETCi_dollars > 0 OR ETCi_hours > 0 OR ETCi_FTEs > 0)
		GROUP BY WBS_ID_WP, period_date
	), Flags As (
		SELECT S.WBS_ID_WP WPID, EPeriod
		FROM LastS S INNER JOIN EPeriod E ON S.WBS_ID_WP = E.WBS_ID_WP
		WHERE DATEDIFF(m,LastS, EPeriod) >= 12
		GROUP BY S.WBS_ID_WP, EPeriod
	)
	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN Flags F ON C.WBS_ID_WP = F.WPID
									  AND C.period_date = F.EPeriod
	WHERE
			upload_ID = @upload_ID
		AND (ETCi_dollars > 0 OR ETCi_hours > 0 OR ETCi_FTEs > 0)
)