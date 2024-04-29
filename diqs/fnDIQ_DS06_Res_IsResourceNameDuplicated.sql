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
  <title>Duplicate Resource Name</title>
  <summary>Is this resource name duplicated across resources?</summary>
  <message>Resource_name repeats across distinct resource_ids.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060247</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsResourceNameDuplicated] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks for resource names that are not unique to a resource_ID.

		To do this, we join the resource table to itself by resource_name (and subproject), and filter
		for rows with differing resource IDs.

		(Note: we group by schedule type, resource id, subproject id, and resource name first to get unique rows.)

		Since we want to do this for both BL & FC schedules, we do this twice, and union the results.

		Results are inserted into a cte, Flags.

		We then join back to DS06 by resource ID, resource name, and schedule type to get our flagged rows.
	*/
	with Resources as (
		--get all resources first
		SELECT resource_ID, resource_name, schedule_type, ISNULL(subproject_ID,'') SubP
		FROM DS06_schedule_resources
		WHERE upload_ID = @upload_ID
	), BL as (
		--Get unique BL Resources
		SELECT * FROM Resources WHERE schedule_type = 'BL' GROUP BY schedule_type, resource_ID, resource_name, SubP
	), FC as (
		--Get unique FC Resources
		SELECT * FROM Resources WHERE schedule_type = 'FC' GROUP BY schedule_type, resource_ID, resource_name, SubP
	), Flags as (
		--Join resources by name and subproject, and look for any joins where resource IDs differ
		SELECT BLName1.*
		FROM BL BLName1 INNER JOIN BL BLName2 ON BLName1.resource_name = BLName2.resource_name AND BLName1.SubP = BLName2.SubP AND BLName1.resource_ID <> BLName2.resource_ID
		UNION
		SELECT FCName1.*
		FROM FC FCName1 INNER JOIN FC FCName2 ON FCName1.resource_name = FCName2.resource_name AND FCName1.SubP = FCName2.SubP AND FCName1.resource_ID <> FCName2.resource_ID
	)

	SELECT R.*
	FROM DS06_schedule_resources R 	INNER JOIN Flags F 	ON R.schedule_type = F.schedule_type
														AND R.resource_ID = F.resource_ID
														AND R.resource_name = F.resource_name
														AND ISNULL(R.subproject_ID,'') = F.SubP
	WHERE upload_id = @upload_ID
	
)