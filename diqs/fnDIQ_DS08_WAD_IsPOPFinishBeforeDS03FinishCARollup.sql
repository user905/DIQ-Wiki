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
  <title>POP Finish Before Cost Finish (CA)</title>
  <summary>Is the POP finish for this Control Account before the last recorded SPAE value in cost?</summary>
  <message>pop_finish_date &lt; max DS03.period_date where BCWS, BCWP, ACWP, or ETC &lt;&gt; 0 (by DS08.WBS_ID &amp; DS03.WBS_ID_CA).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080611</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPFinishBeforeDS03FinishCARollup] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WADs where pop finish < the last recorded DS03.SPAE value.

		(It covers a special case where WADs are at the WP level, 
		but ACWP is at the CA level in cost.)

		First, use the CostFinish cte to load the last recorded SPAE value by CA WBS ID.

		Then rollup the latest revision WP WADs to the CA level with the last POP finish date.

		Compare in the Flags, cte, and then join back to DS08.
	*/
	with CostFinish as (
		--collect SPAE at CA WBS level
		SELECT WBS_ID_CA CAWBS, MAX(period_date) Period
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND (
			BCWSi_dollars <> 0 OR BCWSi_hours <> 0 OR BCWSi_FTEs <> 0 OR
			BCWPi_dollars <> 0 OR BCWPi_hours <> 0 OR BCWPi_FTEs <> 0 OR
			ACWPi_dollars <> 0 OR ACWPi_hours <> 0 OR ACWPi_FTEs <> 0 OR
			ETCi_dollars <> 0 OR ETCi_hours <> 0 OR ETCi_FTEs <> 0
		)
		GROUP BY WBS_ID_CA
	), CAWADRollup as (
		--rollup WP-level WADs to their CAs & collect latest POP finish
		SELECT W.WBS_ID, MAX(W.auth_PM_date) PMAuth, MAX(POP_finish_date) PFinish
		FROM DS08_WAD W  INNER JOIN LatestWPWADRev_Get(@upload_ID) R ON W.WBS_ID_WP = R.WBS_ID_WP 
																	AND W.auth_PM_date = R.PMAuth
		WHERE upload_ID = @upload_id
		GROUP BY W.WBS_ID
	), Flags as (
		-- compare
		SELECT W.WBS_ID, PMAuth
		FROM CAWADRollup W INNER JOIN CostFinish C ON W.WBS_ID = C.CAWBS
													AND W.PFinish < C.[Period]
	)

	SELECT 
		W.*
	FROM 
		DS08_WAD W INNER JOIN Flags F ON W.WBS_ID = F.WBS_ID
										AND W.auth_PM_date = F.PMAuth
	WHERE 
			upload_ID = @upload_ID
		AND ( -- return only if WADs are at the WP level
			SELECT COUNT(*) 
			FROM DS08_WAD 
			WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		) = 0

)