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
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>POP Start After Cost Start (WP)</title>
  <summary>Is the POP start for this Work Package WAD after the first recorded SPAE value in cost?</summary>
  <message>pop_start_date &gt; min DS03.period_date where BCWS, BCWP, ACWP, or ETC &lt;&gt; 0 (by DS08.WBS_ID_WP &amp; DS03.WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080615</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPStartAfterDS03StartWP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WP WADs where pop start > the first recorded DS03.SPAE value.

		First, the CostStart cte gets loaded with the first recorded SPAE value by WP WBS ID.

		Then it's joined back to DS08 and a filter applied comparing pop start to the 
		CostStart period.

		Use LatestWPWADRev_Get to compare only to the latest revision.
	*/

	with CostStart as (
		SELECT WBS_ID_WP WPWBS, MIN(period_date) Period
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (
			BCWSi_dollars <> 0 OR BCWSi_hours <> 0 OR BCWSi_FTEs <> 0 OR
			BCWPi_dollars <> 0 OR BCWPi_hours <> 0 OR BCWPi_FTEs <> 0 OR
			ACWPi_dollars <> 0 OR ACWPi_hours <> 0 OR ACWPi_FTEs <> 0 OR
			ETCi_dollars <> 0 OR ETCi_hours <> 0 OR ETCi_FTEs <> 0
		)
		GROUP BY WBS_ID_WP
	)

	SELECT 
		W.*
	FROM 
		DS08_WAD W 	INNER JOIN LatestWPWADRev_Get(@upload_ID) R ON W.WBS_ID_WP = R.WBS_ID_WP 
																AND W.auth_PM_date = R.PMAuth
					INNER JOIN CostStart C 	ON W.WBS_ID_WP = C.WPWBS 
											AND POP_start_date > C.[Period]
	WHERE 
		upload_ID = @upload_ID
)