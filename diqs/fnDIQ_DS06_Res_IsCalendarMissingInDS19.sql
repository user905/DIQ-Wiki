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
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Calendar Missing In Standard Calendar List</title>
  <summary>Is this calendar name missing in the standard calendar list?</summary>
  <message>calendar_name not found in DS19.calendar_name list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060293</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsCalendarMissingInDS19] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for calendar names that don't exist in DS19.
	*/

	with CALs as (
		SELECT calendar_name CName, ISNULL(subproject_ID,'') SubP
		FROM DS19_schedule_calendar_std 
		WHERE upload_ID = @upload_ID
	)

	SELECT R.*
	FROM DS06_schedule_resources R LEFT OUTER JOIN CALs C ON R.calendar_name = C.CName AND ISNULL(R.subproject_ID,'') = C.SubP
	WHERE 	upload_id = @upload_ID 
		AND C.CName IS NULL
		AND EXISTS (SELECT 1 FROM CALs) --run only if there are any calendars in DS19
	
)