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
  <title>PM Authorization After WP Actual Start</title>
  <summary>Is the PM authorization date for this Work Package WAD later than the WP's Actual Start date?</summary>
  <message>auth_PM_date &gt; DS04.AS_date (by WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080426</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPMAuthAfterDS04WPAS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WP WADs where the PM auth date is after the actual start.
		Note: This applies only to the first revision, which the WAD with the earliest PM auth date.

		To do this, we first collect earliest Actual Starts by WP WBS ID in the cte, WPActStart.
		Compare the WBS_ID to DS01.WBS_ID where type = 'WP' just to play it safe.

		Then, in a second cte, WADByMinAuth, we get the earliest revision, which comes from the earliest
		PM_auth_date.

		A third cte, composite, consolidates these to get WP WBS ID, earliest pm auth date, and Actual Start.

		Join back to DS08 and compare to return problematic rows.
	*/

	with WPActStart as (
		--WP WBS Id with earliest actual start
		SELECT WBS_ID WBS, MIN(AS_date) ActStart
		FROM
			DS04_schedule S 
		WHERE 
				upload_ID = @upload_ID 
			AND AS_date IS NOT NULL 
			AND schedule_type = 'FC'
			AND WBS_ID IN (
				SELECT WBS_ID
				FROM DS01_WBS
				WHERE upload_ID = @upload_ID AND type = 'WP'
			)
		GROUP BY 
			WBS_ID
	), WADByMinAuth as (
		--WP WBS IDs with earliest revisions
		SELECT WBS_ID_WP WPWBS, MIN(auth_PM_date) PMAuth
		FROM DS08_WAD
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		GROUP BY WBS_ID_WP
	), Composite as (
		--WP WBS ID with earliest PM auth and Actual Start
		SELECT W.WPWBS, W.PMAuth, ActS.ActStart
		FROM WADByMinAuth W INNER JOIN WPActStart ActS ON W.WPWBS = ActS.WBS
	)

	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN Composite C 	ON W.WBS_ID_WP = C.WPWBS
											AND W.auth_PM_date = C.PMAuth
											AND W.auth_PM_date > C.ActStart
	WHERE
			upload_ID = @upload_ID  
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) <> ''
)