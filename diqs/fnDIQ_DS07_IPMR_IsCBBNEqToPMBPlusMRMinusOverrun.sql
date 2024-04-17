/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CBB Misaligned with PMB, MR, &amp; Overrun</title>
  <summary>Is the stated CBB value in the IPMR header plus the cost Overrun equal to the PMB plus MR?</summary>
  <message>CBB_dollars &lt;&gt; PMB (DS03.DB + DS07.UB_bgt) + MR_bgt + MR_rpg - Overrun (Sum of DS03.BAC_rpg).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070351</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsCBBNEqToPMBPlusMRMinusOverrun] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Cost as (
		SELECT SUM(BCWSi_dollars) DB, SUM(ISNULL(BAC_rpg,0)) Rpg
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
	)
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND CBB_dollars <> (SELECT DB FROM Cost) + ISNULL(UB_bgt_dollars,0) + --PMB
							ISNULL(MR_bgt_dollars,0) + ISNULL(MR_rpg_dollars,0) - --MR
							(SELECT Rpg FROM Cost) --overrun
)