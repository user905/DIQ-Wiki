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
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Single CAM Across WBS Hierarchy</title>
  <summary>Was only one unique CAM used across the WBS?</summary>
  <message>Only a single CAM found for all WBS Elements; more than one CAM is required across the WBS hierarchy</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1010005</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_DoesOnlyOneCAMExistAcrossWBS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	--test could probably be tweaked
	--returns only the Level 1 WBS, and only one Level 1 in case there are multiple
    SELECT 
        *
    FROM
        DummyRow_Get(@upload_id)
    WHERE (SELECT COUNT(DISTINCT CAM) FROM DS01_WBS	WHERE upload_ID = @upload_id AND TRIM(ISNULL(CAM,'')) <> '') = 1
)