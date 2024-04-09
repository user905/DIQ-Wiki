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
  <title>Comingling of SVT &amp; Non-SVT</title>
  <summary>Does this WBS comingle SVT &amp; Non-SVT tasks?</summary>
  <message>WBS has SVT tasks &amp; Non-SVT tasks (subtype = SVT &amp; subtype &gt;&lt; SVT by WBS_ID).</message>
  <grouping>WBS_ID, schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040114</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_AreSVTsAndNonSVTsComingled] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WBSs with at least one SVT, but where other tasks within the WBS are not SVT.

		To do this, it creates a cte, NonSVT, with a list of WBS IDs and schedule types
		where the subtype is not SVT.

		In another CTE, ToFlag, it then left joins this back to the schedule where subtype *is* SVT (by the WBS IDs and schedule type).

		Any rows where the join is exists (i.e. right side of the join is not null) is a flag
		for that WBS ID as a whole.

		Inserting flags into the #ToFlag temp table, we then join to the schedule DS
		to return all flagged WBS IDs by schedule type.
	*/
	with NonSVT as (
		SELECT WBS_ID, schedule_type
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND ISNULL(subtype,'') <> 'SVT'
		GROUP BY WBS_ID, schedule_type
	), ToFlag as (
		SELECT S.WBS_ID, S.schedule_type
		FROM 
			DS04_schedule S LEFT JOIN NonSVT N 	ON 	S.schedule_type = N.schedule_type
												AND	S.WBS_ID = N.WBS_ID
		WHERE
				S.upload_ID = @upload_ID
			AND ISNULL(S.subtype,'') = 'SVT'
			AND N.WBS_ID IS NOT NULL
	)


	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN ToFlag F ON S.WBS_ID = F.WBS_ID
											AND S.schedule_type = F.schedule_type
	WHERE
		upload_id = @upload_ID

)