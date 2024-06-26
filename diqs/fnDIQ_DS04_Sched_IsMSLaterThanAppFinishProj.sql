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
  <title>Milestone After Approve Finish Project</title>
  <summary>Is this milestone after the Approve Finish Project Milestone?</summary>
  <message>Milestone EF_Date &gt; EF_Date for the Approve Finish Project Milestone (milestone_level = 199) (by subproject_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040193</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsMSLaterThanAppFinishProj] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for milestones with later finish dates than the "approve finish project" MS 
		(ms_level = 199) (by subproject_ID).
		
		First, collect the EF Date for the ms_level = 199 milestone by schedule_type & subproject_ID. (sub-select table MS199).
		Then, join to non-199 level milestones in DS04 by schedule_type & subproject_ID and compare the ES_Dates
	*/

	with MS199 as (
		SELECT EF_Date, schedule_type, ISNULL(subproject_ID,'') SubP
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND milestone_level = 199
	)

	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN MS199 M 	ON S.schedule_type = M.schedule_type
											AND ISNULL(S.subproject_ID,'') = M.SubP
											AND S.EF_date > M.EF_date
	WHERE
			upload_id = @upload_ID
		AND S.milestone_level <> 199
		AND S.milestone_level IS NOT NULL
		

)