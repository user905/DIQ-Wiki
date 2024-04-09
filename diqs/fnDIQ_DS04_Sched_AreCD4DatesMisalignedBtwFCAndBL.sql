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
  <title>CD-4 Early Start or Finish Dates Misaligned Between FC &amp; BL</title>
  <summary>Are the early start or finish dates for the CD-4 milestone misaligned between FC &amp; BL?</summary>
  <message>ES_date or EF_date misaligned for CD-4 in the BL &amp; FC schedules (schedule_type = FC &amp; BL).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040321</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_AreCD4DatesMisalignedBtwFCAndBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(

	/*
		This function looks for CD/BCP milestones where the early start or finish dates are misaligned
		between FC & BL for CD-4 (by subproject_ID).

		Using ctes, we join CD-4 milestones (milestone_level = 190) from FC to BL by task ID, WBS ID, and subproject_ID. 
		We then look for misalignment between their early dates.

		Failed rows are then joined to DS04 to get the output (both BL & FC failures are returned)

		Note: As of Oct 2023, WBS_IDs *must* be unique across all subprojects, which means that we don't necessarily
		need to use the subproject_ID field for the joins. However, knowing how subject to change the schema/DID are,
		it is safer to include the join.
	*/
	with MS190 as (
		SELECT WBS_ID, task_ID, ISNULL(subproject_ID,'') SubP, ES_date, EF_date, schedule_type
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND milestone_level = 190
	),Fails as (
		SELECT F.WBS_ID, F.task_id, F.SubP
		FROM MS190 F INNER JOIN MS190 B ON F.WBS_ID = B.WBS_ID
										AND F.task_ID = B.task_ID
										AND F.SubP = B.SubP
		WHERE
				F.schedule_type = 'FC' 
			AND B.schedule_type = 'BL'
			AND (F.ES_date <> B.ES_date OR F.EF_date <> B.EF_date)
	)

	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Fails F ON S.task_ID = F.task_ID AND S.WBS_ID = F.WBS_ID AND ISNULL(S.subproject_ID,'') = F.SubP
	WHERE
		S.upload_ID = @upload_ID
)