/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS16 Risk Register Tasks</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Likely Impact Cost Dollars Greater Than Max Dollars</title>
  <summary>Are the likely impact dollars for cost greater than the max impact dollars?</summary>
  <message>impact_cost_likely_dollars &gt; impact_cost_max_dollars.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1160563</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS16_RR_Tasks_IsImptCostLikelyGtMax] (
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
		AND impact_cost_likely_dollars > impact_cost_max_dollars
)