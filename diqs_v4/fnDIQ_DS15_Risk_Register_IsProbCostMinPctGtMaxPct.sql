/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS15 Risk Register</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Probability Cost Min % Greater Than Max %</title>
  <summary>Is the minimum probability cost percent greater than the max percent?</summary>
  <message>probability_cost_min_pct &gt; probability_cost_max_pct.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1150553</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS15_Risk_Register_IsProbCostMinPctGtMaxPct] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM DS15_risk_register
	WHERE 
			upload_ID = @upload_ID
		AND probability_cost_min_pct > probability_cost_max_pct
)