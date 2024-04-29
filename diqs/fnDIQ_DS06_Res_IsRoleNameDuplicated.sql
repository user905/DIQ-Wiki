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
  <severity>ALERT</severity>
  <title>Duplicate Role Name</title>
  <summary>Is this role name duplicated across roles?</summary>
  <message>Resource_name repeats across distinct resource_ids.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060252</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsRoleNameDuplicated] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for role names that are not unique to a role_id.
		To do this, we join the resource table to itself by role_name, and filter
		for any rows with differing role IDs.

		(Note: we group by schedule type, role id, and role name first to get unique rows first.)

		Since we want to do this for both BL & FC schedules, we do this twice, and union the results.

		Results are inserted into a cte, Flags.

		We then join back to DS06 by role ID, role name, and schedule type to get our flagged rows.
	*/

	with Flags as (
		SELECT BLName1.role_id, BLName1.role_name, BLName1.schedule_type
		FROM 
			(SELECT role_id, role_name, schedule_type FROM DS06_schedule_resources WHERE upload_ID = @upload_ID AND schedule_type = 'BL' GROUP BY schedule_type, role_id, role_name) BLName1,
			(SELECT role_id, role_name, schedule_type FROM DS06_schedule_resources WHERE upload_ID = @upload_ID AND schedule_type = 'BL' GROUP BY schedule_type, role_id, role_name) BLName2
		WHERE
				BLName1.role_name = BLName2.role_name
			AND BLName1.role_id <> BLName2.role_id
		UNION
		SELECT FCName1.role_id, FCName1.role_name, FCName1.schedule_type
		FROM 
			(SELECT role_id, role_name, schedule_type FROM DS06_schedule_resources WHERE upload_ID = @upload_ID AND schedule_type = 'FC' GROUP BY schedule_type, role_id, role_name) FCName1,
			(SELECT role_id, role_name, schedule_type FROM DS06_schedule_resources WHERE upload_ID = @upload_ID AND schedule_type = 'FC' GROUP BY schedule_type, role_id, role_name) FCName2
		WHERE
				FCName1.role_name = FCName2.role_name
			AND FCName1.role_id <> FCName2.role_id
	)

	SELECT
		R.*
	FROM
		DS06_schedule_resources R 
					INNER JOIN Flags F 	ON R.schedule_type = F.schedule_type
										AND R.role_id = F.role_id
										AND R.role_name = F.role_name
	WHERE
			upload_id = @upload_ID
	
)