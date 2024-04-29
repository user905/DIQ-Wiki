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
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>POP Finish Misaligned with WAD (CA)</title>
  <summary>Is the POP finish for this Control Account misaligned with what is in the WAD?</summary>
  <message>POP_finish_date &lt;&gt; DS08.POP_finish_date (select latest revision; check is on CA level).</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9100471</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsPOPFinishMisalignedWithDS08CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks to see whether CA-level transactions have a pop finish in
		alignment with what is in the WADs.

		To get the WAD Pop finish, we have to pull the latest WAD revision, which we get by
		the max auth_pm_date.

		The cte, WADFinish, collects the latest WAD by WBS_ID (Ds08.WBS_ID is the CA-level WBS),
		with the POP Finish.

		Joining this to DS10 by WBS_ID we then compare the pop finishs.

		Notes: 
		1. WADs & CC log entries can be at either the WP/PP or CA/SLPP level
		2. Cases where both are at the CA/SLPP level are covered below
		3. Cases where WADs are WP-level and CC log entries are CA-level are also covered below.
		4. Cases where WADs & CC log entries are both at the WP level are covered by another WP-level SP.
		5. Cases where WADs are CA-level and CC log entries are WP-level are covered by another special CA-level SP.

	*/

	WITH WADFinish AS (
		--Last CA WAD with POP Finish
		SELECT 
			W.WBS_ID, POP_finish_date
		FROM 
			DS08_WAD W INNER JOIN (
					SELECT WBS_ID, MAX(auth_PM_date) AS lastPMAuth
					FROM DS08_WAD
					WHERE upload_ID = @upload_ID
					GROUP BY WBS_ID
				) LastRev 	ON W.WBS_ID = LastRev.WBS_ID 
							AND W.auth_PM_date = LastRev.lastPMAuth
	)


	SELECT 
		L.*
	FROM 
		DS10_CC_log_detail L INNER JOIN WADFinish W ON L.WBS_ID = W.WBS_ID
	WHERE 
		upload_ID = @upload_ID
	AND L.POP_finish_date <> W.POP_finish_date
)