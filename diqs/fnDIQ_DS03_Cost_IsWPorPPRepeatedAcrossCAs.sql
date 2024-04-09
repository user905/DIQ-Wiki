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
  <severity>ERROR</severity>
  <title>WP or PP Found Across Multiple CAs</title>
  <summary>Is the WP or PP found across multiple Control Accounts?</summary>
  <message>WBS_ID_WP found across distinct WBS_ID_CA.</message>
  <grouping>WBS_ID_CA,WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030106</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsWPorPPRepeatedAcrossCAs] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function finds WP/PP IDs that appear in more than one CA.

		It first populates a cte by joining DS03 cost to itself by WP ID, 
		and then filtering for a difference in CA ID between the two DS03 tables.

		The rows that populate this cte are the CA / WP combinations to flag.

		Join back to DS03 cost to get the rows to return.

		Sample: https://www.db-fiddle.com/f/ek3ToYY5Vu3hKP2niBC55X/2
	*/
	with RepeatWPs as (
		SELECT C1.WBS_ID_CA, C1.WBS_ID_WP
		FROM DS03_cost C1 INNER JOIN DS03_cost C2 ON C1.WBS_ID_WP = C2.WBS_ID_WP 
												AND C1.WBS_ID_CA <> C2.WBS_ID_CA
		WHERE 	TRIM(ISNULL(C1.WBS_ID_WP,'')) <> ''
			AND C1.upload_id = @upload_ID
			AND C2.upload_ID = @upload_ID
		group by 
			C1.WBS_ID_WP, C1.WBS_ID_CA
	)



	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN RepeatWPs R 	ON R.WBS_ID_CA = C.WBS_ID_CA
											AND R.WBS_ID_WP = C.WBS_ID_WP
	WHERE 
		C.upload_ID = @upload_ID
	
)