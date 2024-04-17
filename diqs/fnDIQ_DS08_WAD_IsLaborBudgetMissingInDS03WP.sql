/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP Labor Dollars Missing In Cost</title>
  <summary>Are the labor budget dollars for this WP/PP WAD missing in cost?</summary>
  <message>budget_labor_dollars &gt; 0 &amp; DS03.BCWSi_dollars = 0 where EOC = labor (by WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080415</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsLaborBudgetMissingInDS03WP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with NonLaborWP as (
		SELECT DISTINCT WBS_ID_WP
		FROM DS03_cost
		WHERE 
				upload_ID = @upload_ID 
			AND WBS_ID_WP NOT IN (
				SELECT WBS_ID_WP
				FROM DS03_cost
				WHERE upload_ID = @upload_ID AND EOC = 'Labor' AND BCWSi_dollars <> 0
			)
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN NonLaborWP C ON W.WBS_ID_WP = C.WBS_ID_WP
	WHERE
			upload_ID = @upload_ID  
		AND budget_labor_dollars <> 0
)