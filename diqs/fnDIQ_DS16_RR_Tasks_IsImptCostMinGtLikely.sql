/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS16 Risk Register Tasks</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Minimum Impact Cost Dollars Greater Than Likely Dollars</title>
  <summary>Are the minimum impact dollars for cost greater than the likely impact dollars?</summary>
  <message>impact_cost_minimum_dollars &gt; impact_cost_likely_dollars.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1160564</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS16_RR_Tasks_IsImptCostMinGtLikely] (
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
		AND impact_cost_min_dollars > impact_cost_likely_dollars
)