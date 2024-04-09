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
  <title>50-50 Budget Spread Improperly</title>
  <summary>Is the budget for this 50-50 work spread improperly? (Must be across two consecutive periods and with the same value.)</summary>
  <message>50-50 work (EVT = E) where BCWSi (Dollar, Hours, or FTEs) was found in either one period only or more than two, non-consecutive periods more than 45 days apart, or spread unevenly.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030075</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_Is5050BCWSImproperlySpread] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		UPDATE: Nov 2023. DID v5 introduced is_indirect and replaced Overhead in the EOC with Indirect. 
		This change forced adding is_indirect to the script, as it is now used to define a unique row.

		This DIQ looks for 50/50 work that is not spread across exactly two consecutive periods with the same value.

		The function starts with a CTE that collects current, previous, and next BCWS, 
		using Lead/Lag, which look to next and previous rows, respectively.
		
		Within the CTE are PARTITION BY statements, which are used to treat WP/EOC/is_indirect combinations as groups.
		This ensures we're comparing the same work to itself period over period.
		E.g. We only want to compare the WP's Material (is_indirect = N) in one period to the Material (is_indirect = N) in the next period.

		The CTE collects budget of all three S fields — hours, FTEs, and $ — 
		where EVT = E (50/50) and at least one BCWSi > 0.
		Further, it collects WBS_ID WP, period_date, and EOC.

		Sample: https://www.db-fiddle.com/f/gCQmstKVmn45532URQhFik/6
		(Note: MySQL function IFNULL = T-SQL ISNULL)
	*/

	with SSpread as (
		SELECT 
			WBS_ID_WP, 
			LAG(period_date,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER BY period_date) AS PrevPeriod,
			period_date [Period], 
			LEAD(period_date,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER BY period_date) AS NextPeriod,		
			BCWSi_dollars s_dollars, 
			BCWSi_hours s_hours, 
			BCWSi_FTEs s_ftes,
			ISNULL(LEAD(BCWSi_dollars,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER by period_date),0) AS NextS_dollars,
			ISNULL(LAG(BCWPi_dollars,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER by period_date),0) AS PrevS_dollars,
			ISNULL(LEAD(BCWSi_hours,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER by period_date),0) AS NextS_hours,
			ISNULL(LAG(BCWPi_hours,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER by period_date),0) AS PrevS_hours,
			ISNULL(LEAD(BCWSi_ftes,1) OVER (PARTITION BY WBS_ID_WP, EOC,