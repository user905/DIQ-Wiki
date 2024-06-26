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
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>CA Overhead Dollars Missing In Cost</title>
  <summary>Are the overhead budget dollars for this CA WAD missing in cost?</summary>
  <message>budget_overhead_dollars &gt; 0 &amp; DS03.BCWSi_dollars = 0 where EOC = overhead (by WBS_ID_CA).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080421</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsOverheadBudgetMissingInDS03CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		October 2023: Due to DIDv5 changes, this DIQ has been replaced by fnDIQ_DS08_WAD_IsIndirectBudgetMissingInDS03CA

		This function looks for CA WADs with overhead budget dollars where no overhead BCWSi
		exists in DS03.

		To do this, we create a cte, NonOverheadCA, where we look for CA WBSs that have WP IDs
		that do not exist in the list of overhead WP IDs.

		We then join back to DS08 by CA WP ID to find our output rows.
	*/

	with NonOverheadCA as (
		SELECT DISTINCT WBS_ID_CA
		FROM DS03_cost
		WHERE 
				upload_ID = @upload_ID 
			AND WBS_ID_WP NOT IN (
				SELECT WBS_ID_WP
				FROM DS03_cost
				WHERE upload_ID = @upload_ID AND EOC = 'Overhead' AND BCWSi_dollars <> 0
			)
	)

	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN NonOverheadCA C ON W.WBS_ID = C.WBS_ID_CA
	WHERE
			upload_ID = @upload_ID  
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) = ''
		AND budget_indirect_dollars <> 0
)