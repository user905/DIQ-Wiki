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
  <title>CAM Misaligned with WBS Hierarchy (WP)</title>
  <summary>Is the CAM on this WP/PP WAD misaligned with what is in the WBS hierarchy?</summary>
  <message>DS08.CAM &lt;&gt; DS01.CAM (by WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080408</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsCAMMisalignedWithDS01WP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WP WADs where the last revision CAM name does not match DS01.CAM.

		To do this join LatestWPWADRev_Get to DS08 by WAD_ID & the auth_date to get the most recent WAD revision.
		Also join DS08 to DS01 by WBS ID to compare CAM names.

		In the final join, we filter for anything that doesn't have a WBS_ID_WP as well
		to look only at WP-level WADs.
	*/

	SELECT 
		W.*
	FROM
		DS08_WAD W 	INNER JOIN LatestWPWADRev_Get(@upload_ID) LW ON W.WBS_ID_WP = LW.WBS_ID_WP AND W.auth_PM_date = LW.PMAuth
					INNER JOIN DS01_WBS WBS ON W.WBS_ID_WP = WBS.WBS_ID AND W.CAM <> WBS.CAM
	WHERE
			W.upload_ID = @upload_ID   
		AND WBS.upload_ID = @upload_ID
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) <> ''
)