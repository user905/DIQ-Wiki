/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Zero Unfavorable Cost Inc Percent Threshold</title>
  <summary>Is the unfavorable cost inc percent threshold equal to zero?</summary>
  <message>threshold_cost_inc_pct_unfav = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1070369</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsThresholdCostIncPctUnfavEqToZero] (
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
		AND ISNULL(threshold_cost_Inc_pct_unfav,0) = 0
)