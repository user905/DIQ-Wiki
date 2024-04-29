/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>PM EAC Likely Misaligned with Calculated EAC</title>
  <summary>Is the PM EAC Likely dollars value less than the cost-calculated EAC?</summary>
  <message>EAC_PM_Likely_dollars &lt; sum of DS03.ACWPc + DS03.ETCc + DS07.UB_est_dollars.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070302</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsCalculatedEACGtPMEACLikely] (
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
		AND EAC_PM_likely_dollars < (
			SELECT SUM(ACWPi_dollars) + SUM(ETCi_dollars)
			FROM DS03_cost
			WHERE upload_ID = @upload_ID
		) + ISNULL(UB_est_dollars,0)
)