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
  <severity>WARNING</severity>
  <title>Major Milestone Not Coded As SVT</title>
  <summary>Is this major milestone not coded as an SVT?</summary>
  <message>Major milestone not coded as an SVT (subtype = SVT) (Required on milestone_level = 100-135, 140-170, 190-199, 3xx, and 7xx).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040191</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsMajorMSNotCodedAsSVT] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks to see whether major milestones are marked as SVTs.
		Check is on all approved CD milestones  (milestone_levels 100-135, 140-170, 190, 195),
		planned/estimated completion (170), planned/estimated completion without UB (170), 
		approve finish project (199), customer driven milestones (3xx), and external driven milestones (7xx).
	*/

	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_ID = @upload_ID
		AND (
			milestone_level BETWEEN 100 AND 135 OR
			milestone_level BETWEEN 140 AND 170 OR
			milestone_level BETWEEN 190 AND 199 OR
			milestone_level BETWEEN 300 AND 399 OR
			milestone_level BETWEEN 700 AND 799
		)
		AND ISNULL(subtype,'') <> 'SVT'
)