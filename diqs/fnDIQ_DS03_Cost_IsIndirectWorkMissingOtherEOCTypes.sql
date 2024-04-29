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
  <title>Indirect Not Mingled With Other EOCs</title>
  <summary>Does this CA, SLPP, PP, or WP have only Indirect EOCs?</summary>
  <message>CA, SLPP, PP, or WP with only Indirect.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030098</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsIndirectWorkMissingOtherEOCTypes] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		October 2023: Due to DID v5 changes, DIQ has replaced fnDIQ_DS03_Cost_IsOverheadWorkMissingOtherEOCTypes

		This function looks for CAs or WPs with Indirect but no other EOC.
		
		Step 1. Create a cte, NonIndirect, and load it with CA & WP IDs where EOC <> Indirect AND is_indirect <> Y.
		Step 2. Left join NonIndirect to cost data that has been filtered for EOC = Indirect or is_indirect = Y.
		
		Any missing join is a trip.
	*/

	with NonIndirect AS (
		SELECT WBS_ID_CA CAID, ISNULL(WBS_ID_WP,'') WPID
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC <> 'Indirect' AND ISNULL(is_indirect,'') <> 'Y'
		GROUP BY WBS_ID_CA, ISNULL(WBS_ID_WP,'')
	)

	SELECT C.* 
	FROM DS03_Cost C LEFT OUTER JOIN NonIndirect N 	ON C.WBS_ID_CA = N.CAID AND ISNULL(C.WBS_ID_WP,'') = N.WPID
	WHERE	upload_ID = @upload_ID
		AND (EOC = 'Indirect' OR is_indirect = 'Y')
		AND N.CAID IS NULL
)