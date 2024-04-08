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
  <severity>ALERT</severity>
  <title>Cost Period After PMB End</title>
  <summary>Is this period date after PMB end?</summary>
  <message>Period_date &gt; DS04.ES_Date for milestone_level = 175.</message>
  <grouping>period_date</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030095</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsPeriodAfterPMBEnd] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for Period Dates after PMB end.

		It uses as cte, PMBEndDates, to collect the MS dates for both schedules, 
		with milestone_level = 175, and COALESCE & MAX to pull the last finish date on the milestones,
		whichever exist.

		It then uses another cte, Flags, to compare cost data at the EOC level where:
		1. BCWS > 0 & the period_date is after the PMB End as recorded in the BL schedule; OR
		2. BCWP, ACWP, or ETC > 0 & the period_date is after the PMB End as recorded in the FC schedule.

		Finally, it returns the rows from DS03_Cost where the WBS_ID_CA and WBS_ID_WP are in the Flags cte.
	*/
	with PMBEndDates as (
		SELECT schedule_type, COALESCE(MAX(ES_Date),MAX(EF_DATE)) MSDate  
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND milestone_level = 175
		GROUP BY schedule_type
	), Flags as (
		SELECT WBS_ID_CA, WBS_ID_WP, period_date, EOC
		FROM CostRollupByEOC_Get(@upload_ID)
		WHERE ((	-- if BCWS > 0, compare period_date to BL schedule
				(BCWSi_dollars > 0 OR BCWSi_FTEs > 0 OR BCWSi_hours > 0) AND
				period_date > (SELECT MSDate from PMBEndDates WHERE schedule_type = 'BL')
		) OR (	-- if BCWP, ACWP, or ETC > 0, compare period_date to FC schedule
				(
					BCWPi_dollars > 0 OR BCWPi_FTEs > 0 OR BCWPi_hours > 0 OR 
					ACWPi_dollars > 0 OR ACWPi_FTEs > 0 OR ACWPi_hours > 0 OR 
					ETCi_dollars > 0 OR ETCi_FTEs > 0 OR ETCi_hours > 0
				) AND
				period_date > (SELECT MSDate from PMBEndDates WHERE schedule_type = 'FC')
		))
	)

	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN Flags F 	ON C.WBS_ID_CA = F.WBS_ID_CA 
										AND C.WBS_ID_WP = F.WBS_ID_WP
										AND C.EOC = F.EOC
										AND C.period_date = F.period_date
	WHERE
		upload_ID = @upload_ID

		
)