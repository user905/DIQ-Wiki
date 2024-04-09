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
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Non-Unique Resource or Role</title>
  <summary>Is this resource / role duplicated by schedule type, task ID, EOC, subproject ID, and resource or role ID?</summary>
  <message>Count of schedule_type, task_ID, EOC, subproject_ID and resource_ID or role_id combo &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060259</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks for primary key violations.
		The PK is defined as the combo of: schedule_type, task_ID, resource_ID, role_id, and subproject_ID
	*/

	with Dupes as (
		SELECT schedule_type, task_ID, ISNULL(EOC,'') EOC, ISNULL(resource_ID,'') resource_ID, ISNULL(role_id,'') role_id, ISNULL(subproject_ID,'') SubP
		FROM DS06_schedule_resources
		WHERE upload_id = @upload_ID
		GROUP BY schedule_type, task_ID, ISNULL(EOC,''), ISNULL(resource_ID,''), ISNULL(role_id,''), ISNULL(subproject_ID,'')
		HAVING COUNT(*) > 1
	)
	

	SELECT R.*
	FROM DS06_schedule_resources R INNER JOIN Dupes D 	ON R.schedule_type = D.schedule_type 
														AND R.task_ID = D.task_ID 
														AND ISNULL(R.resource_ID,'') = D.resource_ID 
														AND ISNULL(R.role_id,'') = D.role_id
														AND ISNULL(R.subproject_ID,'') = D.SubP
														AND ISNULL(R.EOC,'') = D.EOC
	WHERE upload_id = @upload_ID
	
)