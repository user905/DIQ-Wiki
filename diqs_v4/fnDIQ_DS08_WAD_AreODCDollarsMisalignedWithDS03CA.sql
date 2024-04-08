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
  <title>CA ODC Dollars Misaligned With Cost</title>
  <summary>Are the ODC budget dollars for this CA WAD misaligned with what is in cost?</summary>
  <message>budget_ODC_dollars &lt;&gt; SUM(DS03.BCWSi_dollars) where EOC = ODC (by WBS_ID_CA).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080392</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_AreODCDollarsMisalignedWithDS03CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for CA WADs where the ODC budget dollars <> ODC BCWSc in DS03.

		To do this, we create a cte, ODCCA, where we get BCWSc_dollars by WBS_ID_CA

		We then join back to DS08 by CA CA ID to find our output rows.
	*/

	with ODCCA as (
		SELECT WBS_ID_CA, SUM(BCWSi_dollars) BCWSc
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'ODC'
		GROUP BY WBS_ID_CA
	)

	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN ODCCA C 	ON W.WBS_ID = C.WBS_ID_CA
										AND budget_ODC_dollars <> C.BCWSc			
	WHERE
			upload_ID = @upload_ID  
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) = ''
		
)