/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CA Labor Dollars Missing In Cost</title>
  <summary>Are the labor budget dollars for this CA WAD missing in cost?</summary>
  <message>budget_labor_dollars &gt; 0 &amp; DS03.BCWSi_dollars = 0 where EOC = labor (by WBS_ID_CA).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080414</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsLaborBudgetMissingInDS03CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with NonLaborCA as (
		SELECT DISTINCT WBS_ID_CA
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
		DS08_WAD W INNER JOIN NonLaborCA C ON W.WBS_ID = C.WBS_ID_CA
	WHERE
			upload_ID = @upload_ID  
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) = ''
		AND budget_labor_dollars <> 0
)