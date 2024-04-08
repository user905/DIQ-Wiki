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
  <title>0-100 Budget Spread Improperly</title>
  <summary>Is the budget for this 0-100 work spread across more than a one period?</summary>
  <message>0-100 work found with BCWSi &gt; 0 (Dollar, Hours, or FTEs) in more than one period.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030074</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_Is0To100BCWSInMoreThanAPeriod] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		The below function looks for 0-100 (EVT = F) work that appears across more than one period.
		
		The function starts with a CTE that collects current and next BCWS, 
		using Lead/Lag, which look to next and previous rows, respectively.

		Within the CTE are PARTITION BY statements, which are used to treat WP/EOC combinations as groups
		so that we're only comparing the budget for the same EOC across periods.
		E.g. We only want to compare the WP's Material in one period to 
		the Material in the next period.		
		
		It then compares BCWSi values (for all three types).
		Any rows where the BCWSi values exist in both periods are reported.

		SAMPLE: https://www.db-fiddle.com/f/m99QsRgotg8qtsspv4aD1U/1
	*/

	with SSpread as (
		SELECT 
			WBS_ID_WP, 
			period_date [Period], 
			LEAD(period_date,1) OVER (PARTITION BY WBS_ID_WP, EOC ORDER BY period_date) AS NextPeriod,	
			BCWSi_dollars s_dollars, 
			BCWSi_hours s_hours, 
			BCWSi_FTEs s_ftes,
			ISNULL(LEAD(BCWSi_dollars,1) OVER (PARTITION BY WBS_ID_WP, EOC ORDER by period_date),0) AS NextS_dollars,
			ISNULL(LEAD(BCWSi_hours,1) OVER (PARTITION BY WBS_ID_WP, EOC ORDER by period_date),0) AS NextS_hours,
			ISNULL(LEAD(BCWSi_ftes,1) OVER (PARTITION BY WBS_ID_WP, EOC ORDER by period_date),0) AS NextS_ftes,
			EOC
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EVT = 'F'
	), 

	/*
		Filter for any rows where BCWSi values exist in both periods.
	*/
	Flags as (
		SELECT WBS_ID_WP, [period], NextPeriod
		FROM SSpread
		WHERE 
			(s_dollars > 0 AND NextS_dollars > 0) OR
			(s_hours > 0 AND NextS_hours > 0) OR
			(s_ftes > 0 AND NextS_ftes > 0)
		GROUP BY WBS_ID_WP, [Period], NextPeriod
	)

	--return rows that match on WBS_ID_WP and Period or next period (since we want to report on both rows)
	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN Flags F 	ON C.WBS_ID_WP = F.WBS_ID_WP 
										AND (C.period_date = F.[Period] OR C.period_date = F.NextPeriod)
	WHERE 
			upload_ID = @upload_ID
		AND C.EVT = 'F'
		AND TRIM(ISNULL(C.WBS_ID_WP,'')) <> ''
)