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
  <title>PM Authorization After CA Actual Start</title>
  <summary>Is the PM authorization date for this Control Account WAD later than the CA's Actual Start date?</summary>
  <message>auth_PM_date &gt; DS04.AS_date (by WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080425</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPMAuthAfterDS04CAAS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for CA WADs where the PM auth date is after the schedule actual start.
		Note: This applies only to the first revision, which the WAD with the earliest PM auth date.

		To do this, we first collect Actual Starts by CA WBS ID in cte, CAActStart. This involves:
		1. collecting AS dates from DS04 by WBS ID (in DS04, WBS ID is the WP WBS ID), 
		2. joining by WBS ID to the AncestryTree function (filtered for type WP AND parent WBS type = CA),
		3. and selecting the MIN(AS_date) by Ancestor WBS ID, i.e. the WBS ID of the CA parent.

		Then, in another cte, WADByMinAuth, we get the earliest revision, which comes from the earliest
		PM_auth_date.

		A third cte, Composite, joins these together. 
		
		Using Composite, we finally join to DS08 by CA WBS ID, PM Auth date (to get only the latest revision),
		and pm auth date > Act Start.
	*/

	with CAActStart as (
		--Schedule CA WBS IDs with earliest actual start
		SELECT A.CAWBS, MIN(S.AS_date) ActStart
		FROM
			(
				SELECT WBS_ID WBS, AS_date 
				FROM DS04_schedule 
				WHERE upload_ID = @upload_ID AND AS_date IS NOT NULL AND schedule_type = 'FC'
			) S INNER JOIN 
			(
				SELECT Ancestor_WBS_ID CAWBS, WBS_ID WBS 
				FROM AncestryTree_Get(@upload_ID) 
				WHERE type = 'WP' AND Ancestor_Type = 'CA'
			) A ON S.WBS = A.WBS
		GROUP BY A.CAWBS
	), WADByMinAuth as (
		--CA-level WADs with earliest revision
		SELECT WBS_ID CAWBS, MIN(auth_PM_date) PMAuth
		FROM DS08_WAD
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		GROUP BY WBS_ID
	), Composite as (
		--composite with CA WBS IDs, with earliest PM auth, and earliest cost actual start.
		SELECT W.CAWBS, W.PMAuth, C.ActStart
		FROM WADByMinAuth W INNER JOIN CAActStart C ON W.CAWBS = C.CAWBS
	)

	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN Composite C 	ON W.WBS_ID = C.CAWBS 
											AND W.auth_PM_date = C.PMAuth
											AND W.auth_PM_date > C.ActStart
	WHERE
			upload_ID = @upload_ID  
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) = ''
)