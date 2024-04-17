/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Negative or Missing Budget Dollars</title>
  <summary>Does this WAD have only negative or zero budget dollar values?</summary>
  <message>budget_labor_dollars &lt;= 0 &amp; budget_labor_hours &lt;= 0 &amp; budget_material_dollars &lt;= 0 &amp; budget_ODC_dollars &lt;= 0 &amp; budget_subcontract_dollars &lt;= 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080404</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsBudgetNegativeOrMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS08_WAD
	WHERE
			upload_ID = @upload_ID  
		AND budget_labor_dollars <= 0 
		AND budget_labor_hours <= 0 
		AND budget_material_dollars <= 0 
		AND budget_ODC_dollars <= 0 
		AND budget_overhead_dollars <= 0 
		AND budget_subcontract_dollars <= 0
)