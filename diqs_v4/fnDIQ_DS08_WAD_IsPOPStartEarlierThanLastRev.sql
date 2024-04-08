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
  <severity>WARNING</severity>
  <title>POP Start Earlier Than Previous Revision</title>
  <summary>Is the POP start of this WAD revision earlier than the POP start of the prior revision?</summary>
  <message>pop_start_date &lt; pop_start_date of prior auth_PM_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080434</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPStartEarlierThanLastRev] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WADs where the pop_start < the pop_start of the previous revision.

		To do this, we first get the previous pop starts.

		Create a cte, LagValues, and insert WBS_ID, WBS_ID_WP, auth PM Date, and the previous pop start date using
		the lag function.

		Partitioning by WBS_ID, WBS_ID_WP groups the WADs together so they're only compared to themselves.
		Order by sorts the revisions by auth PM date.

		Then join back to DS08 and compare.
	*/

WITH LagValues AS (
	SELECT 
		WBS_ID,
		ISNULL(WBS_ID_WP,'') WPWBS,
		auth_PM_date, 
        LAG(pop_start_date) OVER (PARTITION BY WBS_ID, ISNULL(WBS_ID_WP,'') ORDER BY auth_PM_date) AS prevPopStart
  	FROM DS08_WAD
  	WHERE upload_ID = @upload_ID
)

SELECT 
	W.*
FROM 
	DS08_WAD W INNER JOIN LagValues L 	ON W.WBS_ID = L.WBS_ID
										AND ISNULL(W.WBS_ID_WP,'') = L.WPWBS
										AND W.auth_PM_date = L.auth_PM_date
										AND W.POP_start_date < L.prevPopStart
WHERE 
	W.upload_ID = @upload_ID
	


)