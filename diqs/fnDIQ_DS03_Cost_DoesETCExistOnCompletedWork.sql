/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Estimates On Completed Work</title>
  <summary>Are there estimates on this WP even though it is complete?</summary>
  <message>ETCi &lt;&gt; 0 (Dollars, Hours, or FTEs) on completed work (BCWPc / BCWSc &gt; 99%).</message>
  <grouping>WBS_ID_CA, WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030099</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesETCExistOnCompletedWork] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CompleteWork As (
		SELECT WBS_ID_CA, WBS_ID_WP, EOC
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_CA, WBS_ID_WP, EOC
		HAVING ABS(SUM(BCWPi_dollars) / NULLIF(SUM(BCWSi_dollars),0)) > .99 OR
				ABS(SUM(BCWPi_hours) / NULLIF(SUM(BCWSi_hours),0)) > .99 OR
				ABS(SUM(BCWPi_FTEs) / NULLIF(SUM(BCWSi_FTEs),0)) > .99
	)
	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN CompleteWork W ON C.WBS_ID_CA = W.WBS_ID_CA
											  AND C.WBS_ID_WP = W.WBS_ID_WP
											  AND C.EOC = W.EOC
	WHERE
			upload_ID = @upload_ID
		AND (ETCi_dollars > 0 OR ETCi_FTEs > 0 OR ETCi_hours > 0)
)