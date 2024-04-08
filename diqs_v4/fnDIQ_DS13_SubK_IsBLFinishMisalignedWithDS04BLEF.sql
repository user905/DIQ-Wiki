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
  <severity>ALERT</severity>
  <title>BL Finish Misaligned with Baseline Schedule</title>
  <summary>Is the baseline finish date misaligned with the early finish in the baseline schedule?</summary>
  <message>BL_finish_date &lt;&gt; DS04.EF_date where schedule_type = BL (by task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9130522</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS13_SubK_IsBLFinishMisalignedWithDS04BLEF] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks SubK rows where the SubK BL Finish <> BL Schedule ES, by task id.
	*/
	SELECT
		SK.*
	FROM 
		DS13_subK SK INNER JOIN DS04_schedule S ON SK.task_ID = S.task_ID
	WHERE 
			SK.upload_ID = @upload_ID 
		AND S.upload_ID = @upload_ID
		AND SK.BL_finish_date <> S.EF_date
		AND schedule_type = 'BL'

)