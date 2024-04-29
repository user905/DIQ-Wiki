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
  <title>Insufficient Indirect</title>
  <summary>Is this WP or PP lacking sufficient Indirect? (Minimally 10% of the total budget by period)</summary>
  <message>BCWSi_dollars/hours/FTEs for this WP or PP makes up less than 10% of total budget for this period (on Dollars, Hours, or FTEs).</message>
  <grouping>WBS_ID_CA, WBS_ID_WP, period_date</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030094</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsIndirectInsufficient] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		October 2023: DIQ replaces fnDIQ_DS03_Cost_IsOverheadInsufficient. Since Indirects do not have FTEs or Hours, we check only dollars.

		This check looks for rows where Indirect budget (BCWSi dollars) makes up less than 10% of the BCWS for a given WP.
		
		To do this, start with a cte, TotalS, that gets the total BCWSi for each WP/PP/SLPP by period.
		- Use NULLIF on any dollar, hour, or FTE sums to convert zeros to null and prevent divide by zero errors
		
		Then collect all Indirect BCWSi in cte, OvhdS.

		A third cte, Flags, finds the problematic WPs, i.e. where Indirect budget < 10% total budget.

		Joining this back to cost returns our results.
	*/

	with TotalS AS (
		--WP/PP/SLPP total budget (Dollars only)
		SELECT WBS_ID_CA CAID, WBS_ID_WP WPID, period_date Period, NULLIF(SUM(BCWSi_Dollars),0) D
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_CA, WBS_ID_WP, period_date
	), Indirects AS (
		--WP/PP/SLPP total Indirect budget
		SELECT WBS_ID_CA CAID, WBS_ID_WP WPID, period_date Period, SUM(BCWSi_Dollars) D
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (EOC = 'Indirect' or is_indirect = 'Y')
		GROUP BY WBS_ID_CA, WBS_ID_WP, period_date
	), Flags AS (
		--problematic WPs with ovhd < 10% total budget
		SELECT T.CAID, T.WPID, T.Period
		FROM TotalS T INNER JOIN Indirects I ON T.CAID = I.CAID 
											AND T.WPID = I.WPID
											AND T.[Period] = I.[Period]
		WHERE ABS(I.D / T.D) < .1 
	)

	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN Flags F ON C.WBS_ID_CA = F.CAID
										AND C.WBS_ID_WP = F.WPID
										AND C.period_date = F.period
	WHERE
			upload_ID = @upload_ID
		
)