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
  <title>EOCs Improperly Mingled</title>
  <summary>Are material, ODC, subcontract, or labor EOCs comingled in the same task?</summary>
  <message>Task_ID found with combo of material, ODC, subcontract, and/or labor EOC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060264</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreEOCsComingled] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This DIQ looks for EOCs comingled in the same task.
	*/
	SELECT
		R1.*
	FROM
		DS06_schedule_resources R1 INNER JOIN DS06_schedule_resources R2 ON R1.task_ID = R2.task_ID
																		AND R1.schedule_type = R2.schedule_type
																		AND ISNULL(R1.subproject_ID,'') = ISNULL(R2.subproject_ID,'')
																		AND ISNULL(R1.EOC,'') <> ISNULL(R2.EOC,'')
	WHERE
			R1.upload_id = @upload_ID
		AND R2.upload_id = @upload_ID
		AND R1.EOC <> 'Indirect'
		AND R2.EOC <> 'Indirect'
	
)