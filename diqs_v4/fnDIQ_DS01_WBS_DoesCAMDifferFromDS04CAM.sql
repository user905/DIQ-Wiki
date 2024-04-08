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
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Different CAM Name from DS04</title>
  <summary>Does the CAM name for this WBS differ from what is in DS04?</summary>
  <message>CAM name differs between DS01 and DS04.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9010004</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_DoesCAMDifferFromDS04CAM] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This test looks for DS01 WBS IDs that have a different CAM name than the CAM name in DS04.
		Because tasks might have different CAMs in DS04, we do a group by on WBS_ID and then check if the CAM name is the same for all tasks.
		If not, we return the WBS ID and a dummy value, $, to indicate that the CAM name differs, which will force a flag.
		We then join the cte, Sched, back to DS01 by WBS ID and compare.
	*/
	with Sched as (
		SELECT WBS_ID, CASE WHEN Min(ISNULL(CAM,'')) <> MAX(ISNULL(CAM,'')) Then '$' ELSE MIN(ISNULL(CAM,'')) END as 'CAM'
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID
	)

	SELECT 
		W.*
	FROM
		DS01_WBS W INNER JOIN Sched S on W.WBS_ID = S.WBS_ID
	WHERE
			W.upload_ID = @upload_ID
		AND ISNULL(W.CAM,'') <> S.CAM
)