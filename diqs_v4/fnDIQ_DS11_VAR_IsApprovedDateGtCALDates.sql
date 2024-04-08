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
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Approved Date After CAL Dates</title>
  <summary>Is the approved date for this variance later than the dates for the corrective action date?</summary>
  <message>approved_date &gt; DS12.initial_date, DS12.original_due_date, DS12.forecast_due_date, or DS12.closed_date (by CAL_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9110482</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsApprovedDateGtCALDates] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for approval dates > DS12.initial_date, 
		DS12.original_due_date, DS12.forecast_due_date, or DS12.closed_date
		(compare by CAL ID).

		Note that since DS11.CAL_ID is semi-colon delimited, 
		we first must separate out the CAL_IDs by WBS.
		
		The cte, VARsByCAL, uses CROSS APPLY string_split to do exactly this, 
		and then joins to DS12 by CAL_ID in Flags, another cte, where we finally compare dates.
		
		Any returned rows are problem VARs.

		Join back to DS11 to output these VARs.
	*/
	with VARsByCAL as (
		SELECT WBS_ID, approved_date, CAL_ID 
		FROM DS11_variance CROSS APPLY string_split(CAL_ID, ';')
		WHERE upload_ID = @upload_ID
	), Flags as (
		SELECT WBS_ID
		FROM VARsByCAL V INNER JOIN DS12_variance_CAL C ON V.CAL_ID = C.CAL_ID
														AND (
																V.approved_date > C.initial_date 
															OR V.approved_date > C.original_due_date 
															OR V.approved_date > C.forecast_due_date 
															OR V.approved_date > C.closed_date
														)
		WHERE C.upload_ID = @upload_ID
	)

	SELECT 
		V.*
	FROM 
		DS11_variance V INNER JOIN Flags F ON V.WBS_ID = F.WBS_ID
	WHERE 
		V.upload_ID = @upload_ID 
	



)