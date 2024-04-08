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
  <table>DS05 Schedule Logic</table>
  <status>DELETED</status>
  <severity>ALERT</severity>
  <title>Predecessor Subproject ID Mismatched with Schedule</title>
  <summary>Is the subproject ID for this predecessor mismatched with what is in schedule?</summary>
  <message>Predecessor subproject_ID does not align with what is in DS04 schedule (by schedule type, DS05.predecessor_task_ID &amp; DS04.task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9050279</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS05_Logic_IsSubProjMisalignedWithDS04] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for predecessor subproject IDs that do not match with what is in
		DS04.

		This is accomplished via a simple join from DS05 pred ID to DS04 task ID, followed by
		a comparison of the two sub_p IDs.
	*/

	SELECT
		L.*
	FROM
		DS05_schedule_logic L,
		DS04_schedule S
	WHERE
			L.upload_ID = @upload_ID
		AND S.upload_ID = @upload_ID
		AND L.schedule_type = S.schedule_type
		AND L.predecessor_task_ID = S.task_ID
		AND L.subproject_ID <> S.subproject_ID
)