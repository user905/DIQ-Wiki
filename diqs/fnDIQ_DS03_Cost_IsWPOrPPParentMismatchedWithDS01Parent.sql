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
  <title>WP or PP Parent Mismatched with DS01 (WBS) Parent</title>
  <summary>Is the parent ID of this WP or PP misaligned with what is in DS01 (WBS)?</summary>
  <message>The parent ID for this WP or PP does not align with the parent ID found in DS01 (WBS).</message>
  <grouping>WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030105</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsWPOrPPParentMismatchedWithDS01Parent] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



    /*
		This function looks for Cost WP/PP where the CA WBS ID does not match the Parent WBS in DS01.
		
		To do this, collect Parent / Child relationships from DS01.
		Then join to DS03 by DS03.WP WBS ID = DS01.WBS ID 
		and compare the DS03.CA WBS ID <> DS01.Parent WBS ID.
		
		Any returned rows are a mismatch and should be reported.

		Assumption: WP IDs are unique across all Control Accounts.
	*/
	with WBSDict as (
		SELECT WBS_ID Child, parent_WBS_ID Parent
		FROM DS01_WBS 
		WHERE upload_ID = @upload_ID
	)

	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN WBSdict W ON C.WBS_ID_WP = W.Child
										AND C.WBS_ID_CA <> W.Parent
	WHERE 
			upload_ID = @upload_ID
		AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
)