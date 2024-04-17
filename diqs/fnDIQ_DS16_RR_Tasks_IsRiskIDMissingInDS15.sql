/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS16 Risk Register Tasks</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Risk ID Missing In Risk Log</title>
  <summary>Is this risk ID missing in the risk log?</summary>
  <message>Risk_ID not in DS15.risk_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9160570</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS16_RR_Tasks_IsRiskIDMissingInDS15] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS16_risk_register_tasks
	WHERE 
			upload_ID = @upload_ID
		AND risk_ID NOT IN (
			SELECT risk_ID
			FROM DS15_risk_register
			WHERE upload_ID = @upload_ID
		)
)