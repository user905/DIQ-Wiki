/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS09 CC Log</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Risk Missing in Risk Register</title>
  <summary>Is this risk ID missing in the risk register?</summary>
  <message>risk_id missing in DS15.risk_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9090448</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS09_CCLog_IsRiskMisalignedWithDS15] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with RR as (
		SELECT risk_ID
		FROM DS15_risk_register
		WHERE upload_ID = @upload_ID
	)
	SELECT 
		*
	FROM 
		DS09_CC_log
	WHERE
			upload_ID = @upload_ID
		AND risk_ID NOT IN (SELECT risk_ID FROM RR)
		AND (SELECT COUNT(*) FROM RR) > 0 -- run only if there are rows in DS15
)