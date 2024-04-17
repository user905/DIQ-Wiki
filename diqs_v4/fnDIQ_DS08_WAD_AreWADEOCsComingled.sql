/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>WP/PP EOC Comingled (Dollars)</title>
  <summary>Does this WP/PP WAD have comingled EOCs?</summary>
  <message>EOC budget dollars &gt; 0 for at least two non-Overhead EOC types, e.g. budget_labor_dollars &lt;&gt; 0 &amp; budget_material_dollar &lt;&gt; 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080398</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_AreWADEOCsComingled] (
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
		AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		AND (
			(budget_labor_dollars <> 0 AND budget_material_dollars <> 0) OR --labor and another type
			(budget_labor_dollars <> 0 AND budget_ODC_dollars <> 0) OR
			(budget_labor_dollars <> 0 AND budget_subcontract_dollars <> 0) OR
			(budget_material_dollars <> 0 AND budget_ODC_dollars <> 0) OR -- material and another type
			(budget_material_dollars <> 0 AND budget_subcontract_dollars <> 0) OR
			(budget_ODC_dollars <> 0 AND budget_subcontract_dollars <> 0) --ODC and subcontract
		)
)