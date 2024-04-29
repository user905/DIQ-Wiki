/*

The name of the function should include the ID and a short title, for example: DIQ0001_WBS_Pkey or DIQ0003_WBS_Single_Level_1

author is your name.

id is the unique DIQ ID of this test. Should be an integer increasing from 1.

table is the table name (flat file) against which this test runs, for example: "FF01_WBS" or "FF26_WBS_EU".
DIQ tests might pull data from multiple tables but should only return rows from one table (split up the tests if needed).
This value is the table from which this row returns tests.

status should be set to TEST, LIVE, SKIP.
TEST indicates the test should be run on test/development DIQ checks.
LIVE indicates the test should run on live/production DIQ checks.
SKIP indicates this isn't a test and should be skipped.

severity should be set to WARNING or ERROR. ERROR indicates a blocking check that prevents further data processing.

summary is a summary of the check for a technical audience.

message is the error message displayed to the user for the check.

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



	/*
		This function compares the escalation rate % in the IPMR header (DS07) to the
		change in labor rates btw this and last fiscal year.

		Any resource with a labor rate change that exceeds the DS07 escalation rate by 2%
		is flagged.

		NOTE: DOE FY starts in October. So if today is Nov 3, 2023, the FY is 2024.
	*/

	/*
		To run this check, first collect the range for the current FY in cte, CurrFYRange.
	*/
	With CurrSD AS (
		SELECT cpp_status_date SD FROM DS07_IPMR_header WHERE upload_ID = @upload_ID
	),
	CurrFYRange AS (
		-- Get the current FY range based on the SD. 
		-- If we're in October, November, December, the FY is next year, so the range is 01 Oct [Curr Year] - 30 Sep [Next Year]
		-- If before October, the FY range is 01 Oct [Prev Year] - 30 Sep [This Year]
		SELECT 
			CASE 
				WHEN MONTH((SELECT SD FROM CurrSD)) >= 10 THEN CAST(CAST(YEAR((SELECT SD FROM CurrSD)) AS VARCHAR) + '/10/01' AS DATE)
				ELSE CAST(CAST(YEAR((SELECT SD FROM CurrSD)) - 1 AS VARCHAR) + '/10/01' AS DATE) END AS FYStartDate, 
			CASE
				WHEN MONTH((SELECT SD FROM CurrSD)) >= 10 THEN CAST(CAST(YEAR((SELECT SD FROM CurrSD)) + 1 AS VARCHAR) + '/09/30' AS DATE) 
				ELSE CAST(CAST(YEAR((SELECT SD FROM CurrSD)) AS VARCHAR) + '/09/30' AS DATE) END AS FYEndDate
	), 

	--Then collect the labor rates for the previous FY by resource ID.
	PrevFYRates as (
		-- Get Labor rates from the previous FY
		-- Use DATEADD(m, -12, ...) to get rates from the previous FY
		SELECT resource_ID, rate_dollars
		FROM DS21_rates R
		WHERE 
				upload_ID = @upload_ID 
			AND EOC = 'Labor' 
			AND rate_start_date BETWEEN (SELECT DATEADD(m,-12,FYStartDate) FROM CurrFYRange) 
									AND (SELECT DATEADD(m,-12,FYEndDate) FROM CurrFYRange)
	), 

	--Then get % change in labor rates btw last FY & this FY
	RateChange as (
		SELECT Curr.resource_ID, ABS(((Curr.rate_dollars - Prev.rate_dollars) / NULLIF(Prev.rate_dollars,0))) RateChangePct
		FROM DS21_rates Curr INNER JOIN PrevFYRates Prev ON Curr.resource_ID = Prev.resource_ID
		WHERE 
				upload_ID = @upload_ID
			AND Curr.EOC = 'LABOR'
			AND Curr.rate_start_date BETWEEN (SELECT FYStartDate FROM CurrFYRange)
										AND (SELECT FYEndDate FROM CurrFYRange)
	)

	--Finally, join back to DS21 by resource_ID
	--And find any rates where the % change - the escalation rate pct > 2%
	--(Filter to return only rates from the current FY)
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