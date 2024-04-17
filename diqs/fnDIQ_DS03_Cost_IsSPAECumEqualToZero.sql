/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Zero SPAEcum</title>
  <summary>Is this WBS missing Budget, Performance, Actuals, and Estimates?</summary>
  <message>Cumulative BCWS, BCWP, ACWP, and ETC are all equal to zero for this piece of work (Dollars, Hours, and FTEs).</message>
  <grouping></grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030097</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsSPAECumEqualToZero] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with ToTest AS (
		SELECT WBS_ID_CA CAID, ISNULL(WBS_ID_WP,'') WPID, EOC, ISNULL(is_indirect,'') IsInd
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_CA, ISNULL(WBS_ID_WP,''), EOC, ISNULL(is_indirect,'')
		HAVING 
			SUM(BCWSi_Dollars) = 0 AND SUM(BCWSi_hours) = 0 AND SUM(BCWSi_FTEs) = 0 AND
			SUM(BCWPi_Dollars) = 0 AND SUM(BCWPi_hours) = 0 AND SUM(BCWPi_FTEs) = 0 AND
			SUM(ACWPi_Dollars) = 0 AND SUM(ACWPi_hours) = 0 AND SUM(ACWPi_FTEs) = 0 AND
			SUM(ETCi_Dollars) = 0 AND SUM(ETCi_hours) = 0 AND SUM(ETCi_FTEs) = 0
	)
	SELECT C.* 
	FROM DS03_Cost C INNER JOIN ToTest T ON C.WBS_ID_CA = T.CAID
										AND ISNULL(C.WBS_ID_WP,'') = T.WPID
										AND C.EOC = T.EOC
										AND ISNULL(C.is_indirect,'') = T.IsInd
	WHERE upload_ID = @upload_ID
)