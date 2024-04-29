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
  <table>DS05 Schedule Logic</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Schedule Missing Logic</title>
  <summary>Is schedule logic missing for either the BL or FC schedule?</summary>
  <message>Zero logic rows found for either the BL or FC schedule (schedule_type = BL or FC).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1050233</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS05_Logic_IsScheduleMissingLogic] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks to see whether logic is missing for either the BL or FC schedule.
	*/
  with Logic as (
    SELECT schedule_type FROM DS05_schedule_logic WHERE upload_ID = @upload_ID
  )

	SELECT 
      * 
  FROM 
      DummyRow_Get(@upload_ID)	
  WHERE
          (SELECT COUNT(*) FROM Logic WHERE schedule_type = 'BL') = 0
      OR  (SELECT COUNT(*) FROM Logic WHERE schedule_type = 'FC') = 0
)