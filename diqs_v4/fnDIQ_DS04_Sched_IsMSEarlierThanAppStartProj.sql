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
  <title>Milestone Prior To Approve Start Project</title>
  <summary>Is this milestone earlier than the approve start project milestone?</summary>
  <message>Milestone has an early start date (ES_Date) prior to the approve start project milestone (milestone_level = 100).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040192</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsMSEarlierThanAppStartProj] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for milestones with an earlier start date than the "approve start project" MS (ms_level = 100).
		
		To do this, we collect the ES Date for the ms_level = 100 milestone by schedule_type. (sub-select table MS100).
		join to the schedule by schedule_type (filtering for milestones where the ms_level <> 100) 
		and compare the ES_Dates
	*/

	with MS100 as (
		SELECT ES_Date, schedule_type 
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND milestone_level = 100
	)

	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN MS100 M 	ON S.schedule_type = M.schedule_type 
											AND S.ES_date < M.ES_date
	WHERE
			upload_id = @upload_ID
		AND S.milestone_level <> 100
		AND S.milestone_level IS NOT NULL

)