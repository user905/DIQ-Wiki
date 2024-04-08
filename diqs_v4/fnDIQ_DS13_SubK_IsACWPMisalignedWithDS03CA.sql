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
  <title>ACWP Misaligned With Cost (CA)</title>
  <summary>Are the actuals for this subcontract misaligned with what is in cost?</summary>
  <message>ACWPc_dollars &lt;&gt; sum of DS03.ACWPi_dollars where EOC = Subcontract (by DS01.WBS_ID, DS01.parent_WBS_ID, FC DS04.WBS_ID, &amp; DS03.WBS_ID_CA).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9130514</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS13_SubK_IsACWPMisalignedWithDS03CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		NOTE: THIS CHECK IS USED WHEN ACWP IS COLLECTED AT THE CA LEVEL.

		This function looks SubK rows where the�ACWPc_Dollars <> DS03.ACWPc (where EOC = Subcontract).

		Various steps are needed to accomplish this, largely because SubK data is by task_ID,
		while cost data is by CA/WP WBS ID & EOC.

		This means we need to join SubK to DS04 and then roll-up to WBS. But because DS04 is at the WP level,
		and this check is at the CA level, we need to roll up even further to the CA. We do this using 
		the AncestryTree_Get function to do this. 

		We then join back to a rollup of data in DS03. 

		More notes are provided in each step below.
	*/

	with CAACWPCost as (
		--Cost: CA WBS with Subcontract ACWP
		SELECT WBS_ID_CA, SUM(ACWPi_dollars) A
		FROM DS03_cost 
		WHERE upload_ID = @upload_ID AND EOC = 'Subcontract'
		GROUP BY WBS_ID_CA
	), WPACWPSched as (
		--Schedule: WP WBS with SubK ACWP
		SELECT WBS_ID, SUM(ACWPc_Dollars) A
		FROM DS04_schedule S INNER JOIN DS13_subK SK ON S.task_ID = SK.task_ID
		WHERE S.upload_ID = @upload_ID AND SK.upload_ID = @upload_ID AND S.schedule_type = 'FC'
		GROUP BY WBS_ID
	), CAACWPSched as (
		--Schedule: CA WBS with SubK ACWP
		SELECT A.Ancestor_WBS_ID CAWBS, SUM(W.A) A
		FROM WPACWPSched W INNER JOIN AncestryTree_Get(@upload_ID) A ON W.WBS_ID = A.WBS_ID
		WHERE A.[Type] = 'WP' AND A.Ancestor_Type = 'CA'
		GROUP BY A.Ancestor_WBS_ID
	), ProblemCAs as (
		--Comparison of Cost & Schedule
		--Returned rows here are problematic CAs
		SELECT WBS_ID_CA
		FROM CAACWPCost C INNER JOIN CAACWPSched S ON C.WBS_ID_CA = S.CAWBS
		WHERE C.A <> S.A
	), ProblemTasks as (
		--Use AncestryTree_Get to join back to the schedule, filter by CA IDs in ProblemCAs,
		--and select the problem tasks
		SELECT S.task_ID
		FROM DS04_schedule S INNER JOIN AncestryTree_Get(@upload_ID) A ON S.WBS_ID = A.Ancestor_WBS_ID
		WHERE S.upload_ID = @upload_ID AND S.schedule_type = 'FC' AND A.[Type] = 'WP' AND A.Ancestor_Type = 'CA'
		AND A.Ancestor_WBS_ID IN (SELECT WBS_ID_CA FROM ProblemCAs)
	)

	SELECT
		SK.*
	FROM 
		DS13_subK SK INNER JOIN ProblemTasks P ON SK.task_ID = P.task_ID
	WH