/*

The name of the function should include the ID and a short title, for example: DIQ0001_OBS_Pkey or DIQ0003_OBS_Single_Level_1

author is your name.

id is the unique DIQ ID of this test. Should be an integer increasing from 1.

table is the table name (flat file) against which this test runs, for example: "FF01_OBS" or "FF26_OBS_EU".
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
  <table>DS02 OBS</table>
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>OBS ID with Adjacent Letters</title>
  <summary>Does the OBS ID contain letters side by side?</summary>
  <message>OBS ID contains letters adjacent to one another.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS02_OBS_DoesOBSIDContainAdjacentLetters] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(




	/*
		This was deleted on 6 Mar 2023 following discussion about the aims for OBS IDs,
		during which it was determined that there has been no drive to format OBS IDs 
		in any specific way.
	*/

    -- Insert statements for procedure here
	--Note: Double-underscores: underscores work as placeholders for any letters. Two side-by-side would check for any two letters adjacent to one another.
	SELECT 
		* 
	FROM 
		DS02_OBS 
	WHERE 
			upload_ID = @upload_ID 
		AND OBS_ID LIKE '[A-Z][A-Z]' 
)