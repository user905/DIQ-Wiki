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
  <id>16</id>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Single OBS Across WBS Hierarchy</title>
  <summary>Was more than one unique OBS_ID used across the WBS?</summary>
  <message>Only a single OBS_ID found for all WBS Elements; more than one OBS ID is required across the WBS hierarchy</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010006</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_DoesOnlyOneOBSIdExistAcrossWBS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	--tests for a distinct count of all OBS_IDs 
	--test treats nulls the same as blanks and excludes both (a separate test exists for OBS_ID = null/blank)
	--returns only one error at the Level 1 WBS, instead of an error on each line.
    SELECT	
        *
    FROM	
        DummyRow_Get(@upload_id)
    WHERE (SELECT COUNT(DISTINCT OBS_ID) FROM DS01_WBS WHERE upload_ID = @upload_id AND TRIM(ISNULL(OBS_ID, '')) <> '') = 1
)