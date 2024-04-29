/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS15 Risk Register</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Probability Schedule Min Equal To Or Above 98%</title>
  <summary>Is the minimum probability schedule percent equal to or above 98%?</summary>
  <message>probability_schedule_min_pct &gt;= .98.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1150556</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS15_Risk_Register_IsProbSchedMinPctHigh] (
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
		AND probability_schedule_min_pct >= 0.98
)