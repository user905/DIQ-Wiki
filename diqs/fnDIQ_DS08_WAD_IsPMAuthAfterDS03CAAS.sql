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
  <title>PM Authorization After Earliest Recorded CA Performance or Actuals</title>
  <summary>Is the PM authorization date for this Control Account later than the CA' first recorded instance of either actuals or performance?</summary>
  <message>auth_PM_date &gt; minimum DS03.period_date where ACWPi or BCWPi &gt; 0 (by WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080423</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPMAuthAfterDS03CAAS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for CA WADs where the PM auth date is after the first recorded DS03 ACWP or BCWP.
		Note: This applies only to the first revision, which is the WAD with the earliest PM auth date.

		To do this, we first collect the earliest DS03.period_date for each CA WBS ID
		where ACWP or BCWP has been recorded into cte, CAActStart

		Then, in another cte, WADByMinAuth, we get the earliest revision, which comes from the earliest
		PM_auth_date.

		A third cte, Flags, joins these by CA WBS Id, which is then used to join back to DS08
		to get the problematic rows.
	*/
	with CAActStart as (
		--CA WBS IDs with earliest AS date
		SELECT WBS_ID_CA CAWBS, MIN(period_date) ActStart
		FROM DS03_cost
		WHERE 
				upload_ID = @upload_ID 
			AND (
				ACWPi_dollars <> 0 OR ACWPi_dollars <> 0 OR ACWPi_hours <> 0 OR
				BCWPi_dollars <> 0 OR BCWPi_dollars <> 0 OR BCWPi_hours <> 0
			)
		GROUP BY WBS_ID_CA
	), WADByMinAuth as (
		--Earilest WAD revisions by CA WBS ID
		SELECT WBS_ID, MIN(auth_PM_date) PMAuth
		FROM DS08_WAD
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		GROUP BY WBS_ID
	), Composite as (
		--Composite with CA WBS ID, earliest PM auth, and cost Actual start.
		SELECT W.WBS_ID, W.PMAuth, C.ActStart
		FROM WADByMinAuth W INNER JOIN CAActStart C ON W.WBS_ID = C.CAWBS
	)

	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN Composite C 	ON W.WBS_ID = C.WBS_ID 
											AND W.auth_PM_date = C.PMAuth
											AND W.auth_PM_date > C.ActStart
	WHERE
			upload_ID = @upload_ID
		AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
)