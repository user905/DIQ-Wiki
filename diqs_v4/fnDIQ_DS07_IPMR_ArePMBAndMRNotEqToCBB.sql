/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>PMB + MR &lt;&gt; CBB + Overrun</title>
  <summary>Are the PM and MR equal to something other than CBB plus overrun?</summary>
  <message>CBB_dollars != sum of DS08.budget_dollars + UB_bgt + MR_bgt + MR_rpg - sum DS03.BAC_rpg.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070369</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_ArePMBAndMRNotEqToCBB] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with WADBAC as (
		SELECT 
			SUM(ISNULL(budget_labor_dollars,0) + 
				ISNULL(budget_material_dollars,0) + 
				ISNULL(budget_ODC_dollars,0) + 
				ISNULL(budget_overhead_dollars,0) + 
				ISNULL(budget_subcontract_dollars,0)
			) as BAC
		FROM DS08_WAD
		WHERE upload_ID = @upload_ID
	), CostBAC as (
		SELECT SUM(ISNULL(BCWSi_dollars,0)) BAC
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
	), Overrun as (
		SELECT SUM(ISNULL(BAC_Rpg,0)) Overrun
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
	)
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND ABS(ISNULL(CBB_dollars,0) - 
				COALESCE((SELECT TOP 1 BAC FROM WADBAC),(SELECT TOP 1 BAC FROM CostBAC)) - 
				ISNULL(UB_bgt_dollars,0) - 
				ISNULL(MR_bgt_dollars,0) - 
				ISNULL(MR_rpg_dollars,0) + 
				(SELECT TOP 1 Overrun FROM Overrun)
			) > 100
)