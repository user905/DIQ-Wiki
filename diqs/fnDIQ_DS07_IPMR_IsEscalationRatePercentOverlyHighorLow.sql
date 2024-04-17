/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>High or Low Escalation Rate Percent</title>
  <summary>Is the escalation rate percentage exceptionally low (below 3%) or high (above 20%)?</summary>
  <message>escalation_rate_pct &lt;= 0.03 or &gt; 0.2.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1070273</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsEscalationRatePercentOverlyHighorLow] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND (escalation_rate_pct < .03 OR escalation_rate_pct > .2)
)