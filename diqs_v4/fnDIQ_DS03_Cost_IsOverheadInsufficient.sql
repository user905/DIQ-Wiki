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
  <title>Insufficient Overhead</title>
  <summary>Is this SLPP, WP, or PP lacking sufficient Overhead? (Minimally 10% of the total Budget by period)</summary>
  <message>Overhead BCWSi for this SLPP, WP, or PP makes up less than 10% of total budget for this period (on Dollars, Hours, or FTEs).</message>
  <grouping>WBS_ID_CA, WBS_ID_WP, period_date</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030093</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsOverheadInsufficient] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This check looks for rows where Overhead budget (BCWSi) makes up less than 10% of the BCWS for a given WP.
		
		To find this, we start with a cte, TotalS, that gets the total BCWSi for each WP by period.
		(We use NULLIF on any dollar, hour, or FTE sums to convert zeros to null
		and prevents divide by zero errors (Because dividing by null prevents the calculation from occurring.)
		
		We then collect all Overhead BCWSi in cte, OvhdS.

		A third cte, Flags, finds the problematic WPs, i.e. where Overhead budget < 10% total budget.

		Joining this back to cost returns our results.
	*/

	with TotalS AS (
		--WP total budget
		SELECT 
			WBS_ID_CA CAID, WBS_ID_WP WPID, period_date Period,
			NULLIF(SUM(BCWSi_Dollars),0) D, NULLIF(SUM(BCWSi_hours),0) H, NULLIF(SUM(BCWSi_FTEs),0) F
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_CA, WBS_ID_WP, period_date
	), OvhdS AS (
		--WP total overhead budget
		SELECT 
			WBS_ID_CA CAID, WBS_ID_WP WPID, period_date Period,
			SUM(BCWSi_Dollars) D, SUM(BCWSi_hours) H, SUM(BCWSi_FTEs) F
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Overhead'
		GROUP BY WBS_ID_CA, WBS_ID_WP, period_date
	), Flags AS (
		--problematic WPs with ovhd < 10% total budget
		SELECT T.CAID, T.WPID, T.Period
		FROM TotalS T INNER JOIN OvhdS O 	ON T.CAID = O.CAID 
											AND T.WPID = O.WPID
											AND T.[Period] = O.[Period]
		WHERE 
			ABS(O.D / T.D) < .1 OR 
			ABS(O.H / T.H) < .1 OR 
			ABS(O.F / T.F) < .1
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