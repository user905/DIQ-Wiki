/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS15 Risk Register</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Risk Closed Before Risk Tasks Have Completed</title>
  <summary>Is the closed date before all the risk's tasks have finished?</summary>
  <message>closed_date &lt; FC DS04.EF_date (by DS15.risk_ID &amp; DS16.risk_ID, and DS16.task_ID &amp; DS04.task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9150551</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS15_Risk_Register_IsClosedDateLtRiskTaskEFDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with RiskEF as (
		SELECT risk_ID, MIN(EF_date) EF
		FROM DS16_risk_register_tasks R INNER JOIN DS04_schedule S ON R.task_ID = S.task_ID
		WHERE R.upload_ID = @upload_ID AND S.upload_ID = @upload_ID AND S.schedule_type = 'FC'
		GROUP BY risk_ID
	)
	SELECT 
		RR.*
	FROM 
		DS15_risk_register RR INNER JOIN RiskEF R ON RR.risk_ID = R.risk_ID
	WHERE 
			upload_ID = @upload_ID 
		AND RR.closed_date < R.EF
)