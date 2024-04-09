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
  <table>DS03 Cost</table>
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>Cost EOCs Misaligned with Resource EOCs</title>
  <summary>Is the EOC combination for this WP or PP misaligned with the EOC combinations in the Resource (DS06)?</summary>
  <message>EOC combination for this WP or PP is misaligned with EOC combination in Resources (DS06).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030055</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_AreEOCsMisalignedWithEOCsInDS06] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		20 Mar 2023: Deleted. Metric already exists as DS06_Res_IsEOCComboMisalignedWithDS03.
		This test looks for a mismatch between cost EOC combinations and Resource EOC combinations.

		The test first creates a CTE, Resources, that joins DS04 Task IDs to DS06 Task IDs.
		Grouping the results by DS04 WBS ID & DS06 EOC, we then get a list of WBS IDs alongside their EOCs.
	*/

	with Resources As (
		SELECT
			S.WBS_ID, 
			R.EOC
		FROM 
			DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID
		WHERE
				S.upload_ID = @upload_ID
			AND R.upload_ID = @upload_ID
			AND S.schedule_type = 'BL'
			AND R.schedule_type = 'BL'
		GROUP BY
			S.WBS_ID, R.EOC
	)

	/*
		We then left join from cost to the Resources cte by WP WBS ID & EOC, 
		and filter for any cost rows that did not join.
	*/

	SELECT 
		C.* 
	FROM 
		DS03_Cost C LEFT OUTER JOIN Resources R ON C.WBS_ID_WP = R.WBS_ID AND C.EOC = R.EOC
	WHERE
			upload_ID = @upload_ID
		AND R.wbs_ID IS NULL
)