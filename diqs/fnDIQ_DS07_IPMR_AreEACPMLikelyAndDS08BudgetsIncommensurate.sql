/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <type>Performance</type>
  <title>EAC PM Likely Incommensurate with WAD BAC</title>
  <summary>Is the EAC PM likely considerably different from the BAC as reported in the WADs?</summary>
  <message>|(EAC_PM_likey_dollars - sum of DS08.budget_[EOC]_dollars) / sum of DS08.budget_[EOC]_dollars)| &gt; .1 (Or delta &gt; $1,000 where either value = 0).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070362</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_AreEACPMLikelyAndDS08BudgetsIncommensurate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with BAC as (
		SELECT SUM(
			ISNULL(budget_labor_dollars,0) + 
			ISNULL(budget_material_dollars,0) + 
			ISNULL(budget_ODC_dollars,0) +
			ISNULL(budget_indirect_dollars,0) + 
			ISNULL(budget_subcontract_dollars,0)
		) BAC
		FROM DS08_WAD
		WHERE upload_ID = @upload_ID
	)
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND (
			(	--if either is zero, flag if either is more than $1000.
				(ISNULL(EAC_PM_likely_dollars,0) = 0 OR (SELECT TOP 1 BAC FROM BAC) = 0) 
			AND ABS(ISNULL(EAC_PM_likely_dollars,0) - (SELECT TOP 1 BAC FROM BAC)) > 1000)
			OR ABS((ISNULL(EAC_PM_likely_dollars,0) - (SELECT TOP 1 BAC FROM BAC)) / NULLIF((SELECT TOP 1 BAC FROM BAC),0)) > .1
		)
)