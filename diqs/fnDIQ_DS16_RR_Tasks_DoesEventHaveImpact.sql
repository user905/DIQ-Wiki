/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS16 Risk Register Tasks</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Event With Impact</title>
  <summary>Does this event task have an impact value on cost and/or schedule?</summary>
  <message>risk_task_type = Event &amp; non-zero value found in impact_schedule_min_days, impact_schedule_likely_days, impact_schedule_max_days, impact_cost_min_dollars, impact_cost_likely_dollars, or impact_cost_max_dollars.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1160561</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS16_RR_Tasks_DoesEventHaveImpact] (
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
		AND risk_task_type = 'Event'
		AND (
			ISNULL(impact_schedule_min_days, 0) <> 0
			OR ISNULL(impact_schedule_likely_days, 0) <> 0
			OR ISNULL(impact_schedule_max_days, 0) <> 0
			OR ISNULL(impact_cost_min_dollars, 0) <> 0
			OR ISNULL(impact_cost_likely_dollars, 0) <> 0
			OR ISNULL(impact_cost_max_dollars, 0) <> 0
		)
)