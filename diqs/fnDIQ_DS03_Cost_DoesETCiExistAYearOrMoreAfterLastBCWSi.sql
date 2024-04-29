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
  <title>Estimates Found A Year or More After Last Recorded Budget</title>
  <summary>Does this WP or PP show estimates a year or more after the last recorded period of budget?</summary>
  <message>Last period_date where ETCi &lt;&gt; 0 is twelve or more months after last period_date of BCWSi &lt;&gt; 0 (on Dollars, Hours, or FTEs).</message>
  <grouping>WBS_ID_CA,WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030066</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesETCiExistAYearOrMoreAfterLastBCWSi] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for work where the last period of recorded ETCi 
		is >= 12 months after the last period of recorded BCWSi.

		LastS is a cte that finds the last period_date where BCWSi > 0 for each WP.
		EPeriod is a cte that finds the period_date where ETCi > 0 for each WP.
		Flags is a cte where the above two are compared, and where any >= 12 months are apart are flagged.

		Rows returned in Flags are by WP WBS ID & the period_date where ETCi > 0.
	*/
	with LastS as (
		SELECT WBS_ID_WP, MAX(period_date) LastS 
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (BCWSi_dollars > 0 OR BCWSi_hours > 0 OR BCWSi_FTEs > 0)
		GROUP BY WBS_ID_WP
	), EPeriod as (
		SELECT WBS_ID_WP, period_date EPeriod
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (ETCi_dollars > 0 OR ETCi_hours > 0 OR ETCi_FTEs > 0)
		GROUP BY WBS_ID_WP, period_date
	), Flags As (
		SELECT S.WBS_ID_WP WPID, EPeriod
		FROM LastS S INNER JOIN EPeriod E ON S.WBS_ID_WP = E.WBS_ID_WP
		WHERE DATEDIFF(m,LastS, EPeriod) >= 12
		GROUP BY S.WBS_ID_WP, EPeriod
	)

	/*
		Using this we then filter for any WP ID & period_date
		where ETCi > 0.
	*/
	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN Flags F ON C.WBS_ID_WP = F.WPID
									  AND C.period_date = F.EPeriod
	WHERE
			upload_ID = @upload_ID
		AND (ETCi_dollars > 0 OR ETCi_hours > 0 OR ETCi_FTEs > 0)
)