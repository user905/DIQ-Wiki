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
  <table>DS13 Subcontract</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>BAC Misaligned With Cost (WP)</title>
  <summary>Is the budget for this subcontract misaligned with what is in cost?</summary>
  <message>BAC_dollars &lt;&gt; sum of DS03.BCWSi_dollars where EOC = Subcontract (by FC DS04.WBS_ID &amp; DS03.WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9130519</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS13_SubK_IsBACMisalignedWithDS03] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks SubK rows where the�BAC_Dollars <> DS03.DB (where EOC = Subcontract).

		Various steps are needed to accomplish this, largely because SubK data is by task_ID,
		while cost data is by CA/WP WBS ID & EOC.

		This means we need to join SubK to DS04 and then roll-up to WBS (WBS_ID in DS04 is at the WP level). 

		We then join back to a rollup of data in DS03. 

		More notes are provided in each step below.
	*/

	with WPBACCost as (
		--Cost: WP WBS with Subcontract DB (which is sum of BCWSi)
		SELECT WBS_ID_WP, SUM(BCWSi_dollars) BAC
		FROM DS03_cost 
		WHERE upload_ID = @upload_ID AND EOC = 'Subcontract'
		GROUP BY WBS_ID_WP
	), WPBACSched as (
		--Schedule: WP WBS with SubK BCWS
		SELECT WBS_ID, SUM(BAC_dollars) BAC
		FROM DS04_schedule S INNER JOIN DS13_subK SK ON S.task_ID = SK.task_ID
		WHERE S.upload_ID = @upload_ID AND SK.upload_ID = @upload_ID AND S.schedule_type = 'FC'
		GROUP BY WBS_ID
	), ProblemWPs as (
		--Comparison of Cost & Schedule
		--Returned rows here are problematic WPs
		SELECT WBS_ID_WP
		FROM WPBACCost C INNER JOIN WPBACSched S ON C.WBS_ID_WP = S.WBS_ID
		WHERE C.BAC <> S.BAC
	), ProblemTasks as (
		--join back to the schedule to reveal the problem tasks
		SELECT S.task_ID
		FROM DS04_schedule S INNER JOIN ProblemWPs P ON S.WBS_ID = P.WBS_ID_WP
		WHERE S.upload_ID = @upload_ID AND S.schedule_type = 'FC'
	)

	SELECT
		SK.*
	FROM 
		DS13_subK SK INNER JOIN ProblemTasks P ON SK.task_ID = P.task_ID
	WHERE 
		SK.upload_ID = @upload_ID 

)