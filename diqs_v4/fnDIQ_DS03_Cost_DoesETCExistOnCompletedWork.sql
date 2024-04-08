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
  <title>Estimates On Completed Work</title>
  <summary>Are there estimates on this WP even though it is complete?</summary>
  <message>ETCi &lt;&gt; 0 (Dollars, Hours, or FTEs) on completed work (BCWPc / BCWSc &gt; 99%).</message>
  <grouping>WBS_ID_CA, WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030099</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesETCExistOnCompletedWork] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This test looks for completed work that still has estimates (ETCi)

		The test first creates a CTE, CompleteWork, 
		wtih all WPs (by EOC) with BCWP / BCWS > 99% (i.e. really close to done).

		Note: NULLIFs are in the denominators to prevent divide by zero errors. If NULL
		is in the denominator, the equation returns null and won't be comparable to .99
	*/

	with CompleteWork As (
		SELECT WBS_ID_CA, WBS_ID_WP, EOC
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_CA, WBS_ID_WP, EOC
		HAVING ABS(SUM(BCWPi_dollars) / NULLIF(SUM(BCWSi_dollars),0)) > .99 OR
				ABS(SUM(BCWPi_hours) / NULLIF(SUM(BCWSi_hours),0)) > .99 OR
				ABS(SUM(BCWPi_FTEs) / NULLIF(SUM(BCWSi_FTEs),0)) > .99
	)

	/*
		Joining the CTE to Cost, we then filter for all cost rows where ETCi > 0.
		Anything left are our trips.
	*/

	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN CompleteWork W ON C.WBS_ID_CA = W.WBS_ID_CA
											  AND C.WBS_ID_WP = W.WBS_ID_WP
											  AND C.EOC = W.EOC
	WHERE
			upload_ID = @upload_ID
		AND (ETCi_dollars > 0 OR ETCi_FTEs > 0 OR ETCi_hours > 0)
)