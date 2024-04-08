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
  <table>DS15 Risk Register</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Risk Duplicated</title>
  <summary>Is this risk duplicated by risk ID &amp; revision?</summary>
  <message>Count of risk_ID &amp; revision combo &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1150559</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS15_Risk_Register_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks primary key violations in the table.
		The PK is defined as risk_ID and revision (if it exists).
	*/
	with Dupes as (
		SELECT risk_ID, ISNULL(revision,'') revision
		FROM DS15_risk_register
		WHERE upload_ID = @upload_ID
		GROUP BY risk_ID, ISNULL(revision,'')
		HAVING COUNT(*) > 1
	)
	SELECT 
		R.*
	FROM 
		DS15_risk_register R INNER JOIN Dupes D ON R.risk_ID = D.risk_ID 
												AND ISNULL(R.revision,'') = D.revision
	WHERE 
		upload_ID = @upload_ID


)