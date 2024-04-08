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
  <table>DS14 HDV-CI</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Equipment Without Subcontract or Material Resources (FC)</title>
  <summary>Is the equipment for this HDV-CI missing accompanying forecast subcontract or material resources?</summary>
  <message>equipment_ID found where subK_ID not in DS13.subK_ID list with DS06 FC resources of EOC = material or subcontract (by DS14.subK_ID &amp; DS13.subK_ID, and DS13.task_ID &amp; DS06.task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9140542</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS14_HDV_CI_IsEquipMissingDS06SubKOrMatEOCFC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function checks if equipment_ID exists, but where
		a DS06.EOC = material or subcontract resource does not exist for FC resources.

		First get the material & subk resources for each subcontract in SubKResources.
		Then filter for any DS14 items with an equipment ID that do not exist in that list.
	*/
	with SubKResources as (
		--list of subcontract IDs with material and subcontract resources.
		SELECT S.subK_ID
		FROM DS13_subK S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID
		WHERE S.upload_ID = @upload_ID AND R.task_ID = @upload_ID 
		AND R.schedule_type = 'FC' AND R.EOC IN ('Material','Subcontract')
		GROUP BY S.subK_ID
	)

	SELECT 
		*
	FROM
		DS14_HDV_CI H
	WHERE
			upload_ID = @upload_ID
		AND TRIM(equipment_ID) <> ''
		AND subK_ID NOT IN (SELECT subK_ID FROM SubKResources)
)