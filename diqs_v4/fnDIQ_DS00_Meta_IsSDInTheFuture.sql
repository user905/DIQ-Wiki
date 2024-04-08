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
  <table>DS00 Metadata</table>
  <status>DELETED</status>
  <severity>ERROR</severity>
  <title>Future CPP Status Date</title>
  <summary>Is the CPP Status Date in the future?</summary>
  <message>DS00.CPP_Status_Date &gt; today's date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1000003</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS00_Meta_IsSDInTheFuture] (
	@upload_id int = 0
)
RETURNS  @dummy table ( upload_id int )
AS
BEGIN
	/*
		NOTE: STATUS changed to DELETED on 21 Apr 2023. Check will be run during upload into PARS.
		Determine whether CPP SD is after today's date
	*/

	--Datediff will be negative if CPP SD > today's date. 
	IF((SELECT TOP 1 CPP_status_date FROM DS01_WBS WHERE upload_ID = @upload_ID) > GETDATE())
	BEGIN
		INSERT INTO @dummy
		SELECT 
			*
		FROM 
			DummyRow_Get(@upload_ID)
	END

	RETURN
END