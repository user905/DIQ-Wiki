/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS21 Rates</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Negative Or Zero Rate Dollars</title>
  <summary>Is the rate negative or zero?</summary>
  <message>rate_dollars &lt;= 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1210599</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS21_Rates_AreRateDollarsLtEqToZero] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS21_rates
	WHERE 
			upload_ID = @upload_ID
		AND rate_dollars <= 0
)