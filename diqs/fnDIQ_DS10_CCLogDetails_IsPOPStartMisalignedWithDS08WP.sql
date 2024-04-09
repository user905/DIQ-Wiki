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
  <title>POP Start Misaligned with WAD (WP)</title>
  <summary>Is the POP start for this Work Package misaligned with what is in the WAD?</summary>
  <message>POP_start_date &lt;&gt; DS08.POP_start_date (select latest revision; check is on WP/PP level).</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9100476</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsPOPStartMisalignedWithDS08WP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks to see whether WP-level transactions have a pop start in
		alignment with what is in the WADs.

		To get the WAD Pop start, we have to pull the latest WAD revision, which we get by
		the max auth_pm_date.

		The cte, WADStart, collects the latest WAD by WBS_ID_WP (Ds08.WBS_ID_WP is the WP-level WBS),
		with the POP Start.

		Joining this to DS10 by WBS_ID we then compare the pop starts.

		Notes: 
		1. WADs & CC log entries can be at either the WP/PP or CA/SLPP level
		2. Cases where both are at the CA/SLPP level are covered by another SP.
		3. Cases where WADs are WP-level and CC log entries are CA-level are also covered by another SP.
		4. Cases where WADs & CC log entries are both at the WP level are covered below.
		5. Cases where WADs are CA-level and CC log entries are WP-level are covered by another special CA-level SP.

	*/

	WITH WADStart AS (
		--Last WP WAD with POP Start
		SELECT 
			W.WBS_ID_WP, POP_start_date
		FROM 
			DS08_WAD W INNER JOIN (
					SELECT WBS_ID_WP, MAX(auth_PM_date) AS lastPMAuth
					FROM DS08_WAD
					WHERE upload_ID = @upload_ID
					GROUP BY WBS_ID_WP
				) LastRev 	ON W.WBS_ID_WP = LastRev.WBS_ID_WP 
							AND W.auth_PM_date = LastRev.lastPMAuth
	)


	SELECT 
		L.*
	FROM 
		DS10_CC_log_detail L INNER JOIN WADStart W ON L.WBS_ID = W.WBS_ID_WP
	WHERE 
		upload_ID = @upload_ID
	AND L.POP_start_date <> W.POP_start_date
)