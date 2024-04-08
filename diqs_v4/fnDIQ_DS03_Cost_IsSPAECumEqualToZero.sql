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
  <title>Zero SPAEcum</title>
  <summary>Is this WBS missing Budget, Performance, Actuals, and Estimates?</summary>
  <message>Cumulative BCWS, BCWP, ACWP, and ETC are all equal to zero for this WBS (Dollars, Hours, and FTEs).</message>
  <grouping>WBS_ID_CA, WBS_ID_WP, EOC</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030097</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsSPAECumEqualToZero] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This check looks for any SLPP, CA, PP, or WP without any SPAE data.
		It does this by generating a cte, ToTest, with rows grouped by CA ID, WP ID, and EOC,
		where all cumulative SPAE values (Dollars, Hours, and FTEs) equal to zero.

		Any rows that are found are then joined to cost to return the relevant data.
	*/

	with ToTest AS (
		SELECT 
			WBS_ID_CA CAID, WBS_ID_WP WPID, EOC
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_CA, WBS_ID_WP, EOC
		HAVING 
			SUM(BCWSi_Dollars) = 0 AND SUM(BCWSi_hours) = 0 AND SUM(BCWSi_FTEs) = 0 AND
			SUM(BCWPi_Dollars) = 0 AND SUM(BCWPi_hours) = 0 AND SUM(BCWPi_FTEs) = 0 AND
			SUM(ACWPi_Dollars) = 0 AND SUM(ACWPi_hours) = 0 AND SUM(ACWPi_FTEs) = 0 AND
			SUM(ETCi_Dollars) = 0 AND SUM(ETCi_hours) = 0 AND SUM(ETCi_FTEs) = 0
	)

	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN ToTest T ON C.WBS_ID_CA = T.CAID
										AND C.WBS_ID_WP = T.WPID
										AND C.EOC = T.EOC
	WHERE
		upload_ID = @upload_ID
)