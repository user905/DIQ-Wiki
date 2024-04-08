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
  <title>Replan or Repgramming Milestone Without OTB/OTS Date</title>
  <summary>Does this replanning or reprogramming milestone exist without an OTB/OTS Date?</summary>
  <message>Replan or repgroamming milestone found (milestone_level = 138 or 139) without an OTB/OTS Date (DS07 OTB_OTS_Date).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040129</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesReplanOrReprogrammingMSExistWithoutOTBOTSDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for the existence of reprogramming or replan milestones (ms_level 138/139)
		when no OTB_OTS_date exists (in DS07).
	*/
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_ID = @upload_ID
		AND milestone_level IN (138,139)
		AND (SELECT OTB_OTS_date FROM DS07_IPMR_header WHERE upload_ID = @upload_ID) IS NULL

)