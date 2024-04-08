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
  <title>CAL ID Missing in Corrective Action Log</title>
  <summary>Is the CAL ID missing in the Corrective Action Log?</summary>
  <message>CAL_ID missing in DS12.CAL_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9110485</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsCALIDMissingInDS12] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for CAL_IDs missing in DS12.

		Complicating this test is that DS11.CAL_ID, which ties to DS12.CAL_ID, is semi-colon delimited,
		which is why we first create the cte, VARsByCAL.

		Using this we then compare back to DS12 in Flags,
		which we finally use to filter DS11.
	*/
	with VARsByCAL as (
		SELECT WBS_ID, CAL_ID 
		FROM DS11_variance CROSS APPLY string_split(CAL_ID, ';')
		WHERE upload_ID = @upload_ID
	), Flags as (
		SELECT WBS_ID
		FROM VARsByCAL
		WHERE CAL_ID NOT IN (
			SELECT CAL_ID
			FROM DS12_variance_CAL
			WHERE upload_ID = @upload_ID
		)
	)

	SELECT
		*
	FROM 
		DS11_variance
	WHERE 
			upload_ID = @upload_ID
		AND WBS_ID IN (SELECT WBS_ID FROM Flags)
)