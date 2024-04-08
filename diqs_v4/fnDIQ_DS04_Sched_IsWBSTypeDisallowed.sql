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
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Non-WP, PP, or SLPP Type Found in Schedule</title>
  <summary>Is this WBS ID typed as something other than WP, PP, or SLPP in the WBS Dictionary?</summary>
  <message>WBS_ID is not WP, PP, or SLPP type in DS01.type.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040225</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsWBSTypeDisallowed] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WBS_IDs that are not of type WP/PP/SLPP.
		It does this by joining the schedule to a sub-select on DS01.WBS_ID where type is not IN WP/PP/SLPP.
		Any returned results would be a flag.
	*/

	with Disallowed as (
		SELECT WBS_ID 
		FROM DS01_WBS 
		WHERE upload_ID = @upload_ID AND type NOT IN ('WP','PP','SLPP'))

	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Disallowed D ON S.WBS_ID = D.WBS_ID
	WHERE
		upload_id = @upload_ID

)