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
  <severity>ALERT</severity>
  <title>SV Root Cause Narrative Missing CAL Schedule Narrative</title>
  <summary>Is this SVi or SVc VAR narrative missing a corrective action log entry with a schedule narrative?</summary>
  <message>narrative_RC_SVc or narrative_RC_SVi found without DS12.narrative_schedule (by CAL_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9110497</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsSVNarrMissingDS12SchedNarr] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for VARs with SV RC narratives 
		but no DS12 corrective action log narrative entries for schedule. 

		Complicating this test is that DS11.CAL_ID, which ties to DS12.CAL_ID, is semi-colon delimited.
		
		This means we first split the CAL field and place it alongside WBS_ID in VARsByCAL
		(filtering for RC SV narratives first).

		Then we compare to DS12 in Flags.
	*/

	with VARsByCAL as (
		--WBS IDs with CAL IDs broken out into rows
		--filtered for rows where there is a SV RC narrative
		SELECT WBS_ID, CAL_ID 
		FROM DS11_variance CROSS APPLY string_split(CAL_ID, ';')
		WHERE 
				upload_ID = @upload_ID 
			AND (TRIM(ISNULL(narrative_RC_SVi,'')) <> '' OR TRIM(ISNULL(narrative_RC_SVc,'')) <> '')
	), Flags as (
		--WBS IDs where no schedule narrative exists in DS12
		--either because the row is missing or because the narrative_schedule is blank
		SELECT V.WBS_ID
		FROM VARsByCAL V LEFT OUTER JOIN DS12_variance_CAL C ON V.CAL_ID = C.CAL_ID
		WHERE 
				C.upload_ID = @upload_ID 
			AND (TRIM(ISNULL(C.narrative_schedule,'')) = '' OR C.CAL_ID IS NULL)
	)

	SELECT
		*
	FROM 
		DS11_variance
	WHERE 
			upload_ID = @upload_ID
		and WBS_ID IN (SELECT WBS_ID FROM Flags)
)