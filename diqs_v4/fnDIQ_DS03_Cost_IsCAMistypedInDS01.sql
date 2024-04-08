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
  <title>CA Type Mismatched With WBS Dictionary</title>
  <summary>Is this Control Account WBS ID typed as something other than CA in the WBS Dictionary?</summary>
  <message>WBS_ID_CA not in DS01.WBS_ID list where DS01.type = CA.</message>
  <grouping>WBS_ID_CA</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030083</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsCAMistypedInDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		The below looks for DS03 CA WBS IDs that are not marked as type CA in DS01.

		It joins DS03.WBS_ID to DS01.WBS_ID, and then filters for anything not marked as DS01.type = 'CA'. 
		The check excludes DS03.EVT <> 'K' to avoid checks on SLPPs.
	*/
	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN DS01_WBS W ON C.WBS_ID_CA = W.WBS_ID
	WHERE 
			C.upload_ID = @upload_ID
		AND	W.upload_ID = @upload_ID
		AND W.[type] <> 'CA'
		AND ISNULL(EVT,'') <> 'K'
)