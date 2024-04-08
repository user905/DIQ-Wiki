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
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <type>Performance</type>
  <title>Incommensurate Future Budget &amp; Estimates</title>
  <summary>Is there more than a 50% delta between future BCWS &amp; ETC dollars for this chunk of work? (Or, if BCWS is missing, is there at least $1,000 of ETC without BCWSi?)</summary>
  <message>|(BCWSi_dollars - ETCi_dollars) / BCWSi_dollars|&gt; .5 (or ETCi_dollars &gt; 1000 where BCWSi = 0) where period_date &gt; CPP_status_date.</message>
  <grouping>period_date</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030046</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_AreBCWSiAndETCiIncommensurate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks at future periods where a major delta exists between BCWS & ETC dollars.
		It does this by joining to CostRollupByEOC_Get, which rolls up to the EOC level first.
		
		Threshold is 50%, or a delta greater than $1000.
	*/
	SELECT 
			C.* 
	FROM 
			DS03_Cost C INNER JOIN CostRollupByEOC_Get(@upload_ID) R ON C.PERIOD_DATE = R.PERIOD_DATE
																	 AND C.WBS_ID_CA = R.WBS_ID_CA
																	 AND ISNULL(C.WBS_ID_WP,'') = R.WBS_ID_WP
																	 AND C.EOC = R.EOC
	WHERE
			upload_ID = @upload_ID
			AND C.period_date > C.CPP_status_date
			AND R.period_date > C.CPP_status_date
			AND (
					(ISNULL(R.bcwsi_dollars,0) = 0 AND ABS(ISNULL(R.BCWSi_dollars,0) - ISNULL(R.ETCi_dollars,0)) > 1000)
				OR 	ABS((ISNULL(R.BCWSi_dollars,0) - ISNULL(R.ETCi_dollars,0)) / NULLIF(R.BCWSi_dollars,0)) > .5
			)
)