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
  <UID>9100473</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsPOPFinishRollupMisalignedWithDS08CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks to see whether CA-level transactions have a pop finish in
		alignment with what is in the WADs.

		The function covers a special case where WADs are at the CA-level, 
		but CC log entries are at the WP level.

		To start, the cte, WADFinish, collects the latest WAD by WBS_ID 
		(DS08.WBS_ID is the CA-level WBS) with the POP Finish.

		CACLog then gets POP finishs by CA WBS ID, which it pulls from AncestryTree_Get.
		
		The third cte, FlagsByCAWBS, then joins the above two result sets by CA WBS ID 
		and compares WAD POP Finish to CC Log POP Finish.

		Any flags here are problematic CA WBS IDs.

		Now, because the CC Log entries might be at the WP level, we need to get the WP WBS IDs
		that make up the above CA WBS IDs.

		To do this we create a fourth cte, FlagsByWPWBS, which joins back to AncestryTree_Get,
		this time by the Ancestor's WBS ID, to find every WP WBS ID that belongs to one of the problem CAs.

		Joining this back to DS10 we then get our result set.
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
	), CACCLog AS (
		--WP level CC log entries rolled up to the CA level, along with latest POP finish
		--Filter for only items of type WP/PP where the ancestor is a CA/SLPP
		SELECT A.Ancestor_WBS_ID CAWBS, MAX(POP_finish_date) PopFinish
		FROM DS10_CC_log_detail L INNER JOIN AncestryTree_Get(@upload_ID) A ON L.WBS_ID = A.WBS_ID
		WHERE L.upload_ID = @upload_ID AND A.[Type] IN ('WP','PP') AND A.Ancestor_Type IN ('CA','SLPP')
		GROUP BY A.Ancestor_WBS_ID
	), FlagsByCAWBS AS (
		--CA WBS IDs where WAD POP finish <> CC log POP finish
		SELECT W.WBS_ID
		FROM WADFinish W INNER JOIN CACCLog C ON W.WBS_ID = C.CAWBS
		WHERE W.POP_finish_date <> C.PopFinish
	), FlagsByWPWBS AS (
		--WP WBS IDs that make up the above CA WBSs
		--Join back to AncestryTree, bu