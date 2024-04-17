/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS15 Risk Register</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Risk Missing Impact Task</title>
  <summary>Is this risk missing an impact task in the risk log?</summary>
  <message>risk_ID not in DS16.task_ID list where risk_task_type = Impact.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9150560</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS15_Risk_Register_IsRiskMissingDS16ImpactTask] (
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
		AND risk_ID NOT IN (
			SELECT risk_ID
			FROM DS16_risk_register_tasks
			WHERE upload_ID = @upload_ID AND risk_task_type = 'Impact'
		)
)