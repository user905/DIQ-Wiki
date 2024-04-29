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
  <title>CD / BCP Milestones Out of Sequence</title>
  <summary>Is this CD or BCP out of sequence chronologically in the milestone list?</summary>
  <message>CD or BCP milestone (milestone_level = 1xx) occurs out of sequence with successive milestone (ES_date &gt; ES_date of the successive milestone).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040107</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_Are1xxMSsOutOfOrder] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks at the 1xx milestones to see whether they are in chronological order.
		Exceptions include the 3A-F & 4A-F milestone groups, which can be out of order relative to the others,
		but must be in order within their relative groups.

		To do this, it selects the ordered list of MS (ordered by schedule type and ms_level) 
		into a cte, MSList, alongside the ES_Date of the successive MS (using LEAD).

		Because the 3x & 4x groups are special, we need to load these from separate selects so that
		the LEAD function doesn't pull the ES date from MSs outside of their relative sub-group.

		(NOTE: We use a union to stack the results on top of one another.)

		Next, create a Flags cte to find problem Milestones.

		Finally, we join MSList back to schedule, and filter for any MSs
		where the ES_date > ES_date of the successive MS.

		NOTE 1: There is one exception to the rule: milestone_level = 170 (planned/estimated completion without UB)
		should have the same date as milestone_level = 175 (End of PMB)

		NOTE 2, ON LEAD: Lead uses PARTITION BY schedule_type to ensure that the current row looks only at the next row
		**within the same schedule**.
		Example: https://www.db-fiddle.com/f/kSDF7NFY4vhoJQGpYYYq7C/3
	*/

		-- DECLARE @MSList TABLE (ES_date date, NextES date, milestone_level int, schedule_type varchar(2), task_ID varchar(50))
		-- INSERT INTO @MSList 
		with MSList as (
			SELECT 	ES_date, 
					LEAD(ES_date,1) OVER (PARTITION BY schedule_type ORDER BY milestone_level) as NextES, 
					schedule_type, 
					task_ID, 
					milestone_level, 
					LEAD(milestone_level,1) OVER (PARTITION BY schedule_type ORDER BY milestone_level) as NextMilestoneLevel,
					ISNULL(subproject_ID,'') SubP
			FROM DS04_schedule
			WHERE upload_ID = @upload_ID 
				AND (
						milestone_level BETWEEN 100 AND 139
					OR milestone_level = 150
					OR milestone_level BETWEEN 170 AND 199
				)
			UNION
			--CD3x		
			SELECT 	ES_date, 
					LEAD(ES_date,1) OVER (PARTITION BY schedule_type ORDER BY milestone_level) as NextES, 
					schedule_type, 
					task_ID, 
					milestone_level,
					LEAD(milestone_level,1) OVER (PARTITION BY schedule_type ORDER BY milestone_level) as NextMilestoneLevel,
					ISNULL(subproject_ID,'') SubP
			FROM DS04_schedule
			WHERE upload_ID = @upload_ID AND milestone_level BETWEEN 140 AND 145
			UNION
			--CD4x
			SELECT 	ES_date, 
					LEAD(ES_date,1) OVER (PARTITION BY schedule_type ORDER BY milestone_level) as NextES, 
					schedule_type, 
					task_ID, 
					milestone_level, 
					LEAD(milestone_level,1) OVER (PARTITION BY schedule_type ORDER BY milestone_level) as NextMilestoneLevel,
					ISNULL(subproject_ID,'') SubP
			FROM DS04_schedule
			WHERE upload_ID = @upload_ID AND milestone_level BETWEEN 160 AND 165
		), Flags as (
			SELECT * 
			FROM MSList
			WHERE 				
					--ms_level 170 & 175 should have the same date;
					milestone_level = 170 AND NextMilestoneLevel = 175 AND ES_date > NextES 
					--milestone_levels that are not 170 or where the NextMilestoneLevel is not 175, should not occur on the same date or after the next milestone;
				OR 	((milestone_level <> 170 OR NextMilestoneLevel <> 175) AND milestone_level <> NextMilestoneLevel AND ES_date >= NextES) 
						--milestones that are the same level should occur on the same date (this is to ensure the same milestone in different subprojects )
				-- OR milestone_level = NextMilestoneLevel AND ES_date <> NextES
		)

	SELECT S.*
	FROM DS04_schedule S INNER JOIN Flags F ON S.task_ID = F.task_ID
											AND S.schedule_type = F.schedule_type
											AND ISNULL(S.subproject_ID,'') = F.SubP	
	WHERE upload_id = @upload_ID
)