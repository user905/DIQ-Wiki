/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP Indirect Dollars Missing In Cost</title>
  <summary>Are the indirect budget dollars for this WP/PP WAD missing in cost?</summary>
  <message>budget_indirect_dollars &gt; 0 &amp; DS03.BCWSi_dollars = 0 where EOC = indirect (by WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080433</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsIndirectBudgetMissingInDS03WP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with IndirectWPs as (
		SELECT WBS_ID_WP
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (EOC = 'Indirect' OR is_indirect = 'Y') AND BCWSi_dollars <> 0 AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
	), NonIndirectWP as (
		SELECT DISTINCT WBS_ID_WP
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND WBS_ID_WP NOT IN (SELECT WBS_ID_WP FROM IndirectWPs)
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN NonIndirectWP C ON W.WBS_ID_WP = C.WBS_ID_WP
	WHERE
			upload_ID = @upload_ID  
		AND budget_indirect_dollars <> 0
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) <> ''
)