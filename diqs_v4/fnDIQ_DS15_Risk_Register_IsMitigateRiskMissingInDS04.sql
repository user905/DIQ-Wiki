/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS15 Risk Register</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Risk Mitigation Task Missing In Baseline Schedule</title>
  <summary>Is this risk mitigation task missing in the baseline schedule?</summary>
  <message>risk_handling = Mitigate &amp; risk_ID not in BL DS04.RMT_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9150552</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS15_Risk_Register_IsMitigateRiskMissingInDS04] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS15_risk_register
	WHERE 
			upload_ID = @upload_ID
		AND risk_handling = 'Mitigate'
		AND risk_ID NOT IN (
			SELECT RMT_ID
			FROM DS04_schedule
			WHERE upload_ID = @upload_ID AND schedule_type = 'BL'
		)
)