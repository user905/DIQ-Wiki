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
  <title>Invalid Use of NA EVT</title>
  <summary>Has EVT of type NA been selected for non-Control Account data?</summary>
  <message>EVT = NA on WP row or CA row not marked as type 'CA' in DS01 (WBS).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030109</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsNAEVTBeingUsedImproperly] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for EVT = NA among Non-CA rows.

		The function filters for EVT = NA and either
		1a. rows with WP IDs (which by definition cannot be CAs) or
		1b. rows with CA IDs not marked as CA type in DS01.
		
	*/

	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND EVT = 'NA'
		AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
)