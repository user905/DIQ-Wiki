/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS09 CC Log</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Risk Missing</title>
  <summary>Are risk IDs missing in the CC log?</summary>
  <message>Count of CC log entries &gt; 5 &amp; Count of risk_id = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1090449</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS09_CCLog_IsRiskMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CCLogEntries as (
		SELECT COUNT(*) CCLogEntries
		FROM DS09_CC_log 
		WHERE upload_ID = @upload_ID
	), RiskRows as (
		SELECT COUNT(*) RiskRows
		FROM DS09_CC_log 
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(risk_ID,'')) <> ''
	)
	SELECT 
		*
	FROM 
		DummyRow_Get(@upload_ID)
	WHERE
			(SELECT TOP 1 CCLogEntries FROM CCLogEntries) > 5 --more than 5 CC log entries?
		AND (SELECT TOP 1 RiskRows FROM RiskRows) = 0 --no risks?
)