/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>TAB Misaligned with BAC Repgrogramming &amp; CBB</title>
  <summary>Does TAB equal something other than CBB plus BAC Reprogramming?</summary>
  <message>TAB_dollars &lt;&gt; CBB_dollars + SUM(DS03.BAC_rpg).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070361</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsTABNEqToBACRpgPlusCBB] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND ISNULL(TAB_dollars,0) <> ISNULL(CBB_dollars,0) + (SELECT SUM(ISNULL(BAC_rpg, 0)) FROM DS03_cost WHERE upload_ID = @upload_ID) 
)