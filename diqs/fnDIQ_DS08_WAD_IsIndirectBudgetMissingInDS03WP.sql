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
  <title>WP Indirect Dollars Missing In Cost</title>
  <summary>Are the indirect budget dollars for this WP/PP WAD missing in cost?</summary>
  <message>budget_indirect_dollars &gt; 0 &amp; DS03.BCWSi_dollars = 0 where EOC = indirect (by WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080433</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsIndirectBudgetMissingInDS03WP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		October 2023: Due to DIDv5 changes, this DIQ has replaced fnDIQ_DS08_WAD_IsOverheadBudgetMissingInDS03CA

		This function looks for WP WADs with indirect budget dollars where no indirect BCWSi
		exists in DS03.

		Step 1. Dump all WPs with Indirect data & BCWSi_dollars>0 into cte, IndirectWPs.
		
		Step 2. Dump all WPs that are NOT in IndirectWPs into NonIndirectWP. This is our list of WPs that do not have indirect in DS03.

		Step 3. Join the step 2 WPs to DS08 WPs with budget_indirect_dollars <> 0 to find our output rows.
	*/
	with IndirectWPs as (
		SELECT WBS_ID_WP
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (EOC = 'Indirect' OR is_indirect = 'Y') AND BCWSi_dollars <> 0 AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
	), NonIndirectWP as (
		SELECT DISTINCT WBS_ID_WP
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND WBS_ID_WP NOT IN (SELECT WBS_ID_WP FROM IndirectWPs)
	)

	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN NonIndirectWP C ON W.WBS_ID_WP = C.WBS_ID_WP
	WHERE
			upload_ID = @upload_ID  
		AND budget_indirect_dollars <> 0
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) <> ''
)