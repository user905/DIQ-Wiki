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
  <severity>WARNING</severity>
  <title>BL Resource Missing Among FC Resoures</title>
  <summary>Is this BL resource missing among the FC resources?</summary>
  <message>Combo of task_ID, resource_ID, role_ID, &amp; EOC (where schedule_type = BL) not found in DS06 (where schedule_type = FC).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060260</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsBLResourceMissingInFC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(

	/*
		Looks for BL resources that are missing in FC.

		First collect FC Resources into a CTE, 
		then left outer join BL resources to FC resources and filter out the rows that match.
	*/
	with FCRes as (
		SELECT task_ID, TRIM(ISNULL(resource_ID,'')) ResID, TRIM(ISNULL(role_ID,'')) RoleID, EOC
		FROM DS06_schedule_resources
		WHERE upload_id = @upload_ID AND schedule_type = 'FC'
	)

	SELECT
		BLR.*
	FROM
		DS06_schedule_resources BLR LEFT OUTER JOIN FCRes ON BLR.task_ID = FCRes.task_ID 
														 AND TRIM(ISNULL(BLR.resource_ID,'')) = FCRes.ResID 
														 AND TRIM(ISNULL(BLR.role_ID,'')) = FCRes.RoleID
														 AND BLR.EOC = FCRes.EOC
	WHERE
			upload_id = @upload_ID
		AND schedule_type = 'BL'
		AND FCRes.task_ID IS NULL
	
)