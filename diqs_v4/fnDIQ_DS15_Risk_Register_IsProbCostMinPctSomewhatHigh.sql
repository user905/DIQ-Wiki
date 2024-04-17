/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS15 Risk Register</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Probability Cost Min Between 92 - 98%</title>
  <summary>Is the minimum probability cost percent between 92 &amp; 98%?</summary>
  <message>probability_cost_min_pct &gt;= .92 &amp; &lt; .98.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1150554</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS15_Risk_Register_IsProbCostMinPctSomewhatHigh] (
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
		AND probability_cost_min_pct >= 0.92
		AND probability_cost_min_pct < 0.98
)