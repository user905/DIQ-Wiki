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
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Quantitative Risk Analysis Confidence Level for Cost Below 95% Following BCP</title>
  <summary>Is the quantitative risk analysis confidence level for cost below 95% following a BCP?</summary>
  <message>BCP found (milestone_level = 131 - 135) with quantitative risk analysis confidence level for cost below 95% (DS07.QRA_CL_cost_pct).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040116</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesBCPExistWithCostRiskConfidenceLevelBelow95Percent] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for the existence of BCPs (ms_level 131-135)
		when the quantitative risk analysis confidence level for cost is below 95%.
	*/

	with QRACL as (
		SELECT ISNULL(QRA_CL_cost_pct,0) QRACL 
		FROM DS07_IPMR_header 
		WHERE upload_ID = @upload_ID
	)
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_ID = @upload_ID
		AND milestone_level BETWEEN 131 AND 135
		AND (SELECT QRACL FROM QRACL) < .95
)