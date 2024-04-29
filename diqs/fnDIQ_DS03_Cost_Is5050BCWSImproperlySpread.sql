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
			ISNULL(LEAD(BCWSi_ftes,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER by period_date),0) AS NextS_ftes,
			ISNULL(LAG(BCWPi_ftes,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER by period_date),0) AS PrevS_ftes,
			EOC,
			ISNULL(is_indirect,'') IsInd
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EVT = 'E'
	), 

	/*
		Using the CTE, we then dump the data into another cte table, Flags.
		While doing so, we filter for rows where current BCWSi > 0 and at least one the following conditions is true:
		1. Is there no BCWS in the previous period *and* none in the next period?
		2. Is there BCWS in the previous period *and* in the next period?
		3. Are the next or previous periods more than 45 days from the current?
		4. Are the next or previous period's values not within $100 / 1 hour of the current period's values.

		The reason to filter for BCWS > 0 ahead of time is to reduce the number of overal trips.
		We only want rows with actual data in them that are marked 50/50.

		For dollars & hours we allow for a cushion of $100 and 1 hours, respectively.
		This is where ABS(s_dollars/hours) > 100/1 comes in.
	*/
	Flags as (
		SELECT WBS_ID_WP, [period], EOC, IsInd
		FROM SSpread
		WHERE 
			(ABS(s_dollars) > 100 OR ABS(s_hours) > 1 OR s_ftes > 0) --Get only rows where |BCWSi| > 100 (threshold of $100/1hr)
			AND ((
					(ABS(PrevS_dollars) > 100 AND ABS(NextS_dollars) > 100) OR -- Are the prev & next $ amounts both > $100? (Both provided)
					(ABS(PrevS_dollars) < 100 AND ABS(NextS_dollars) < 100) -- Are the prev & next $ amounts both < $100? (Both missing)
				) OR (
					(ABS(PrevS_hours) > 1 AND ABS(s_hours) > 1) OR -- Are the prev & next hours both > 1? (Both provided)
					(ABS(PrevS_hours) < 1 AND ABS(s_hours) < 1) -- Are the prev & next hours both < 1? (Both missing)
				) 
				OR (
					(PrevS_ftes = 0 AND NextS_ftes = 0) OR --Are prev/next FTEs both = 0?
					(PrevS_ftes > 0 AND NextS_ftes > 0) --Are prev/next FTEs both > 0?
				) 
				OR (
					DATEDIFF(day, PrevPeriod, [period]) >= 45 OR DATEDIFF(day, [period], NextPeriod) >= 45 --Are the prev/next periods > 45 days from the current?
				) OR (
					ABS(s_dollars - PrevS_dollars) > 100 OR ABS(s_dollars - NextS_dollars) > 100 OR --Is there more than a $100 delta between current period and prev/next?
					ABS(s_hours - PrevS_hours) > 1 OR ABS(s_hours - NextS_hours) > 1 --Is there more than a 1 hour delta between current period and prev/next?
				)
			)
	)

	-- select * from Flags

	/*
		Lastly we join our trip rows back to the Cost data and return the results.
		We join by WP ID, EOC, is_indirect, and Period date, since those are what uniquely
		define the row of data that failed.

		Assumption: WPs are unique across all Control Accounts.
	*/

	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN Flags F 	ON C.WBS_ID_WP = F.WBS_ID_WP
										AND C.period_date = F.period
										AND C.EOC = F.EOC
										AND ISNULL(C.is_indirect,'') = F.IsInd
	WHERE 
			upload_ID = @upload_ID
		AND EVT = 'E'
		AND TRIM(ISNULL(C.WBS_ID_WP,'')) <> ''

       

	
)