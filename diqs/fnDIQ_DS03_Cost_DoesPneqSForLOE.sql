/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>BCWSi &lt;&gt; BCWPi for LOE</title>
  <summary>Is there a delta between BCWS and BCWP for this LOE work?</summary>
  <message>BCWSi &lt;&gt; BCWPi for LOE work (Dollar, Hours, or FTEs).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030067</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesPneqSForLOE] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN CostRollupByEOC_Get(@upload_ID) R ON C.period_date = R.period_date 
																 AND C.WBS_ID_CA = R.WBS_ID_CA
																 AND ISNULL(C.WBS_ID_WP,'') = R.WBS_ID_WP
																 AND C.EOC = R.EOC
	WHERE 
			upload_ID = @upload_ID
		AND C.period_date < CPP_status_date
		AND EVT = 'A'
		AND (
			ABS(R.BCWSi_dollars - R.BCWPi_dollars) > 100 OR
			R.BCWSi_FTEs <> R.BCWPi_FTEs OR
			ABS(R.BCWSi_hours - R.BCWPi_hours) > 1
		)
)