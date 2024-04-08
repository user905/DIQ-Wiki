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
  <severity>ALERT</severity>
  <type>Performance</type>
  <title>POP Finish Before Forecast Early Finish (CA)</title>
  <summary>Is the POP finish for this Control Account WAD before the forecast early finish?</summary>
  <message>pop_finish &lt; DS04.EF_date where schedule_type = FC (by DS08.WBS_ID &amp; DS04.WBS_ID via DS01.WBS_ID &amp; DS01.parent_WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080605</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPFinishBeforeDS04FCEFDateCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for CA WADs where POP finish < DS04.EF_date (FC).

		To do this, first create a table where we get MAX(EF) by CA WBS ID. Join the AncestryTree_Get
		function, filtered for type = 'CA' and parent type = 'CA', to DS04 to do this.

		Then join the cte to DS08.WBS_ID and make the comparison.

		Also join to LatestCAWADRev_Get to only compare the last revision
	*/

	with CAFinish as (
		SELECT A.CAWBS, MAX(S.EF_date) EF
		FROM
			DS04_schedule S INNER JOIN (
				SELECT Ancestor_WBS_ID CAWBS, WBS_ID WPWBS 
				FROM AncestryTree_Get(@upload_ID) 
				WHERE type = 'WP' AND Ancestor_Type = 'CA') A ON S.WBS_ID = A.WPWBS
		WHERE
				S.upload_ID = @upload_ID
			AND S.schedule_type = 'FC'
		GROUP BY A.CAWBS
	)

	SELECT 
		W.*
	FROM
		DS08_WAD W 	INNER JOIN CAFinish C ON W.WBS_ID = C.CAWBS
										  AND W.POP_finish_date <> C.EF
					INNER JOIN LatestCAWADRev_Get(@upload_ID) R ON W.WBS_ID = R.WBS_ID
																AND W.auth_PM_date = R.PMAuth 
	WHERE
			upload_ID = @upload_ID  
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) = ''
)