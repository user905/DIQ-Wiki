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
  <severity>WARNING</severity>
  <title>BCWSi &lt;&gt; BCWPi for LOE</title>
  <summary>Is there a delta between BCWS and BCWP for this LOE work?</summary>
  <message>BCWSi &lt;&gt; BCWPi for LOE work (Dollar, Hours, or FTEs).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030067</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesPneqSForLOE] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	--DIQ checks for deltas between S & P hours/ftes/dollars at the EOC level.
	--Thresholds: $100 or 1 hour. No threshold for FTEs
	--DIQ uses CostRollupByEOC_Get to analyze at the EOC level, rather than at EVT.
	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN CostRollupByEOC_Get(@upload_ID) R ON C.period_date = R.period_date 
																 AND C.WBS_ID_CA = R.WBS_ID_CA
																 AND ISNULL(C.WBS_ID_WP,'') = R.WBS_ID_WP
																 AND C.EOC = R.EOC
	WHERE 
			upload_ID = @upload_ID
		AND C.period_date < CPP_status_date
		AND EVT = 'A'
		AND (
			ABS(R.BCWSi_dollars - R.BCWPi_dollars) > 100 OR
			R.BCWSi_FTEs <> R.BCWPi_FTEs OR
			ABS(R.BCWSi_hours - R.BCWPi_hours) > 1
		)
	
)