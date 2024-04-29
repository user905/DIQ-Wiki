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
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <type>Performance</type>
  <title>POP Start After Schedule Actual Start (WP)</title>
  <summary>Is the POP start for this Work Package WAD after the actual start in the forecast schedule?</summary>
  <message>pop_start &gt; DS04.AS_date where schedule_type = FC (by DS08.WBS_ID_WP &amp; DS04.WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080617</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPStartAfterDS04ASDateWP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WP WADs where POP start > DS04.AS_date (FC).

		To do this, first create a table where we get MIN(AS) by WP WBS ID.

		Then join the cte to DS08.WBS_ID and make the comparison.
	*/

	with WPActS as (
		SELECT WBS_ID WBS, MAX(AS_date) ActS
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
		GROUP BY WBS_ID
	)

	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN WPActS A 	ON W.WBS_ID_WP = A.WBS	
										AND W.POP_start_date > A.ActS
	WHERE
		upload_ID = @upload_ID  
)