/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS21 Rates</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Labor Rate Escalation Exceeds Allowable Rate in the IPMR Header</title>
  <summary>Did the rate change for this labor resource between last FY and this FY exceed the allowed rate as provided in the IPMR header?</summary>
  <message>|(DS21.rate_dollars for current FY - DS21.rate_dollars previous FY) / DS21.rate_dollars previous FY| - DS07.escalation_rate_pct &gt; .02 (by resource_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9210603</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS21_Rates_IsLaborRateChangeGtDS07EscalationRate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	With CurrSD AS (
		SELECT cpp_status_date SD FROM DS07_IPMR_header WHERE upload_ID = @upload_ID
	),
	CurrFYRange AS (
		SELECT 
			CASE 
				WHEN MONTH((SELECT SD FROM CurrSD)) >= 10 THEN CAST(CAST(YEAR((SELECT SD FROM CurrSD)) AS VARCHAR) + '/10/01' AS DATE)
				ELSE CAST(CAST(YEAR((SELECT SD FROM CurrSD)) - 1 AS VARCHAR) + '/10/01' AS DATE) END AS FYStartDate, 
			CASE
				WHEN MONTH((SELECT SD FROM CurrSD)) >= 10 THEN CAST(CAST(YEAR((SELECT SD FROM CurrSD)) + 1 AS VARCHAR) + '/09/30' AS DATE) 
				ELSE CAST(CAST(YEAR((SELECT SD FROM CurrSD)) AS VARCHAR) + '/09/30' AS DATE) END AS FYEndDate
	), 
	PrevFYRates as (
		SELECT resource_ID, rate_dollars
		FROM DS21_rates R
		WHERE 
				upload_ID = @upload_ID 
			AND EOC = 'Labor' 
			AND rate_start_date BETWEEN (SELECT DATEADD(m,-12,FYStartDate) FROM CurrFYRange) 
									AND (SELECT DATEADD(m,-12,FYEndDate) FROM CurrFYRange)
	), 
	RateChange as (
		SELECT Curr.resource_ID, ABS(((Curr.rate_dollars - Prev.rate_dollars) / NULLIF(Prev.rate_dollars,0))) RateChangePct
		FROM DS21_rates Curr INNER JOIN PrevFYRates Prev ON Curr.resource_ID = Prev.resource_ID
		WHERE 
				upload_ID = @upload_ID
			AND Curr.EOC = 'LABOR'
			AND Curr.rate_start_date BETWEEN (SELECT FYStartDate FROM CurrFYRange)
										AND (SELECT FYEndDate FROM CurrFYRange)
	)
	SELECT 
		R.*
	FROM 
		DS21_rates R INNER JOIN RateChange RC ON R.resource_ID = RC.resource_ID
	WHERE 
			upload_ID = @upload_ID
		AND RC.RateChangePct - (SELECT ISNULL(escalation_rate_pct,0) FROM DS07_IPMR_header WHERE upload_ID = @upload_ID) > .02
		AND rate_start_date BETWEEN (SELECT FYStartDate FROM CurrFYRange)
								AND (SELECT FYEndDate FROM CurrFYRange)
)