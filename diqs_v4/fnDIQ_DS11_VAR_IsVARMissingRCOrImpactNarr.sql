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
  <title>Root Cause And/Or Impact Narrative Missing</title>
  <summary>Is this VAR missing either a root cause or an impact narrative (or both)?</summary>
  <message>VAR is missing either a RC SV or CV narrative or an impact narrative (or both).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1110494</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsVARMissingRCOrImpactNarr] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks to confirm that VARs have at least one RC narrative or overall narrative 
		and one impact narrative (combo does not matter)
	*/
	SELECT
		*
	FROM 
		DS11_variance
	WHERE 
			upload_ID = @upload_ID
		AND NOT (
				TRIM(ISNULL(narrative_RC_CVc,'')) <> ''
			OR	TRIM(ISNULL(narrative_RC_CVi,'')) <> ''
			OR	TRIM(ISNULL(narrative_RC_SVc,'')) <> ''
			OR	TRIM(ISNULL(narrative_RC_SVi,'')) <> ''
			OR	TRIM(ISNULL(narrative_overall,'')) <> ''
		)
		AND (
				TRIM(ISNULL(narrative_impact_cost,'')) <> ''
			OR 	TRIM(ISNULL(narrative_impact_schedule,'')) <> ''
			OR 	TRIM(ISNULL(narrative_impact_technical,'')) <> ''
		)
)