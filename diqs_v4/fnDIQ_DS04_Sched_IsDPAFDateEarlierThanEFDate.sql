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
  <title>Actual Finish Prior to Early Finish Along the Driving Path</title>
  <summary>Does this FC task along the Driving Path have an Actual Finish earlier than the BL Early Finish?</summary>
  <message>FC AF_date &lt; BL EF_date where driving_path = Y (compare by task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040166</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsDPAFDateEarlierThanEFDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for tasks on the BL driving path 
		where the FC AF date is earlier than the BL EF date.

		The query joins a DP BL tasks (via BLDPTask) to the FC and compares
		the FC AF Date to the BL EF Date.
	*/
	with BLDPTask as (
		SELECT task_ID, EF_Date 
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND schedule_type = 'BL' AND driving_path = 'Y'
	)
	

	SELECT
		F.*
	FROM
		DS04_schedule F INNER JOIN BLDPTask B ON F.task_ID = B.task_ID
											 AND F.AF_date < B.EF_date
	WHERE
			F.upload_id = @upload_ID
		AND F.schedule_type = 'FC'
		
)