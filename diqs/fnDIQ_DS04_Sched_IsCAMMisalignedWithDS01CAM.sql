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
  <severity>ALERT</severity>
  <title>CAM Misaligned with DS01 (WBS)</title>
  <summary>Is the CAM for this task misaligned with what is in DS01 (WBS)?</summary>
  <message>CAM name does not align with CAM in DS01 (WBS).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040148</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsCAMMisalignedWithDS01CAM] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN (SELECT WBS_ID, CAM FROM DS01_WBS WHERE upload_ID = @upload_ID) W ON S.WBS_ID = W.WBS_ID
																									AND S.CAM <> W.CAM
	WHERE
		S.upload_id = @upload_ID
)