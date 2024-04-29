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
  <title>Improper Collection of Indirect</title>
  <summary>Is indirect collected at the CA level or via the EOC field (rather than using is_indirect)?</summary>
  <message>EOC = Indirect, is_indirect missing, or is_indirect = Y/N found at the CA level (where WBS_ID_WP is blank).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1030115</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsIndirectCollectedImproperly] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This DIQ looks for cost data that does not conform to Scenario B:
		WBS_ID_CA	WBS_ID_WP	is_indirect	EOC		EVT	BCWSi		BWCPi		ACWPi		ETCi
		01.01.01	01.01.01.01	N			labor	C	$direct 	$direct		$direct		$direct
		01.01.01	01.01.01.01	Y			labor	C	$indirect	$indirect	$indirect	$indirect
	*/

	
	SELECT *
	FROM DummyRow_Get(@upload_ID)
	WHERE EXISTS (
		SELECT * 
		FROM DS03_cost
		WHERE upload_ID = @upload_id
			AND (
					is_indirect IS NULL  --is_indirect is unused
				OR (TRIM(ISNULL(WBS_ID_WP,'')) = '' AND ISNULL(is_indirect,'') <> '') --CA data with is_indirect
				OR EOC = 'Indirect' --indirect in the EOC column
			)

	)
)