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
  <title>Multiple Replanning Milestones In Current Period</title>
  <summary>Do multiple replanning milestones exist in the current period?</summary>
  <message>Multiple replanning milestones (milestone_level = 139) found in the current period (ES_date within 35 days of CPP Status Date).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040136</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoMultipleReplanMSsExistInTheCurrentPeriod] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(

	/*
		This function looks for the existence of multiple replan MSs (ms_level = 139) within the current period.
		
		It first gets the replan MSs within the last 35 days of the CPP status date.
		It then counts those by schedule type.
		The flags cte then finds any with COUNT > 1, and joins back to DS04 to return the results.
	*/

WITH ReplanMS AS (
		-- get the Replan MSs by schedule type & task ID
		SELECT schedule_type, task_ID
		FROM DS04_schedule
		WHERE upload_ID = @upload_id AND milestone_level = 139
		AND DATEDIFF(d, COALESCE(ES_date,EF_date), CPP_status_date) < 35
		AND DATEDIFF(d, COALESCE(ES_date,EF_date), CPP_status_date) >= 0 --ignore if the MS is after the status date
	), ReplanCount AS (
		-- count by schedule type
        SELECT schedule_type, COUNT(*) AS cnt
        FROM ReplanMS
        GROUP BY schedule_type
		HAVING COUNT(*) > 1
    ), Flags as (
        -- problem MSs
        SELECT R.schedule_type, R.task_ID
        FROM ReplanMS R INNER JOIN ReplanCount Cnt ON R.schedule_type = Cnt.schedule_type
        WHERE Cnt.cnt > 1
    )

    SELECT
       S.*
    FROM
        DS04_schedule S INNER JOIN Flags F ON S.schedule_type = F.schedule_type AND S.task_ID = F.task_ID
    WHERE
        upload_ID = @upload_id
)