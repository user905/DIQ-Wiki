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
  <title>WBS With Only ZBA Tasks</title>
  <summary>Does this WBS have only ZBA tasks?</summary>
  <message>WBS has no other task subtype other than ZBA (subtype = ZBA).</message>
  <grouping>WBS_ID, schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040135</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesWBSHaveOnlyZBATasks] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WBS IDs made up only of ZBA tasks.

		To do this, it creates a cte, NonZBA, with a list of WBS IDs and schedule types
		where the subtype is not ZBA.

		It then left joins this back to the schedule where subtype *is* ZBA (by the WBS IDs and schedule type).

		Any rows where the join is missing (i.e. right side of the join is null) is a flag.

		Inserting flags into the #ToFlag temp table, we then join to the schedule DS
		to return all flagged WBS IDs by schedule type.
	*/
	with NonZBA as (
		SELECT WBS_ID, schedule_type
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND ISNULL(subtype,'') <> 'ZBA'
		GROUP BY WBS_ID, schedule_type
	), ToFlag as (
		SELECT S.WBS_ID, S.schedule_type
		FROM 
			DS04_schedule S LEFT JOIN NonZBA N 	ON 	S.schedule_type = N.schedule_type
												AND	S.WBS_ID = N.WBS_ID
		WHERE
				S.upload_ID = @upload_ID
			AND ISNULL(S.subtype,'') = 'ZBA'
			AND N.WBS_ID IS NULL
	)

	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN ToFlag F ON S.WBS_ID = F.WBS_ID
											AND S.schedule_type = F.schedule_type
	WHERE
			upload_id = @upload_ID
)