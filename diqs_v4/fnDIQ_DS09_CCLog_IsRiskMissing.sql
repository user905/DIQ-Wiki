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
  <table>DS09 CC Log</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Risk Missing</title>
  <summary>Are risk IDs missing in the CC log?</summary>
  <message>Count of CC log entries &gt; 5 &amp; Count of risk_id = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1090449</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS09_CCLog_IsRiskMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		This function looks for CC logs with > 5 entries and no risk IDs.
	*/
	with CCLogEntries as (
		SELECT COUNT(*) CCLogEntries
		FROM DS09_CC_log 
		WHERE upload_ID = @upload_ID
	), RiskRows as (
		SELECT COUNT(*) RiskRows
		FROM DS09_CC_log 
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(risk_ID,'')) <> ''
	)
	SELECT 
		*
	FROM 
		DummyRow_Get(@upload_ID)
	WHERE
			(SELECT TOP 1 CCLogEntries FROM CCLogEntries) > 5 --more than 5 CC log entries?
		AND (SELECT TOP 1 RiskRows FROM RiskRows) = 0 --no risks?
	

)