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
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>CPP Status Date Missing From Cost Periods</title>
  <summary>Is the CPP Status Date missing from the period dates in the cost file?</summary>
  <message>DS00.CPP_Status_Date not in DS03.period_date list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1000001</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS00_Meta_IsCPPMissingInDS03PeriodDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(	/*
		Check to see if the CPP Status Date exists in the DS03.period_dates list. 

		To do this, look to see if any rows exist where DS03.cpp_status_date = DS03.period_date.

		Do not flag if the CPP Status Date is after the last period_date in the cost file.
	*/

	with Periods as (
		SELECT cpp_status_date, period_date
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
	)

	SELECT 
		*
	FROM 
		DummyRow_Get(@upload_ID)
	WHERE 
		-- are there any rows where CPP SD = period_dates? If not, possible flag.
			(SELECT COUNT(*) FROM Periods WHERE period_date = CPP_status_date) = 0
		-- is the CPP SD after the last period_date in the cost file? If not, flag.
		AND (SELECT COUNT(*) FROM Periods WHERE cpp_status_date > (SELECT MAX(period_date) from periods)) = 0
)