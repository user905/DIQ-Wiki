/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS16 Risk Register Tasks</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Impact Schedule Day Spread Missing</title>
  <summary>Are the minimum, likely, and max impact schedule days all equivalent?</summary>
  <message>impact_schedule_minimum_days = impact_schedule_likely_days = impact_schedule_max_days.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1160568</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS16_RR_Tasks_IsImptSchedMissingSpread] (
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
		AND impact_schedule_min_days = impact_schedule_likely_days
		AND impact_schedule_likely_days = impact_schedule_max_days
)