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
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Cost Periods Not One Month Apart</title>
  <summary>Is this period date less than 20 or more than 36 days apart from either the previous or next period?</summary>
  <message>Period_date is not within 20-36 days from previous or next period.</message>
  <grouping>period_date</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030057</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_ArePeriodsLT20OrGT36DaysApart] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for consecutive Period Dates within the PMB that are not between 
		20-36 days apart.

		It creates a cte, PMBPeriod, with a list periods that are prior to the DS04.ES_date
		of milestone_level = 175 (end of PMB). (We use MAX(ES_Date) in case there are several
		MSs that represent this milestone.)

		Alongside the periods are the period prior and the period after, which will be used for comparison
	*/

	with PMBPeriods AS (
		SELECT 
			period_date Period, 
			LAG(period_date,1) OVER (ORDER BY period_date) as PrevPeriod,
			LEAD(period_date,1) OVER (ORDER BY period_date) as NextPeriod
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND period_date < (
			SELECT MAX(ES_Date) 
			FROM DS04_schedule
			WHERE upload_ID = @upload_ID AND schedule_type = 'BL' AND milestone_level = 175
		)
		GROUP BY period_date
	)

	/*
		Using PMBPeriods we then sub-select for Periods where prevperiod/nextperiod
		are not within 20-36 of the current period.
	*/

	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND period_date IN (
			SELECT Period
			FROM PMBPeriods
			WHERE 
				DATEDIFF(day,PrevPeriod,Period) NOT BETWEEN 20 AND 36 OR
				DATEDIFF(day,Period,NextPeriod) NOT BETWEEN 20 AND 36
		)
)