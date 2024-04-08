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
  <title>Task With Units % Complete Not Materially Resource Loaded</title>
  <summary>Does this task with units % complete have resources with an EOC other than material?</summary>
  <message>Task with units % complete type (PC_type = units) has non-material EOC resources (DS06.EOC &lt;&gt; material).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040219</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsUnitsPCTypeResourcedWithNonMaterialEOC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for tasks where the % complete type = units, but not all
		DS06 resource EOCs for that task are material.

		It joins schedule where pc_type = 'units' to a sub-select of resources where EOC is not material.
		Any returned rows are flags.
	*/
	with NonMatRes as (
		SELECT schedule_type, task_ID 
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID AND EOC <> 'material'
	)

	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN NonMatRes R 	ON S.task_ID = R.task_ID
												AND S.schedule_type = R.schedule_type
	WHERE
			upload_id = @upload_ID
		AND PC_type = 'units'

)