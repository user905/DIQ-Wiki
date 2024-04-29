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
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>VAC without Root Cause Narrative (Unfavorable)</title>
  <summary>Is a root cause narrative missing for this CA where the VAC is tripping the unfavorable dollar threshold?</summary>
  <message>|BCWSi_dollars - ACWPi_dollars - ETCi_dollars|) &gt; |DS07.threshold_cost_VAC_dollar_unfav| &amp; DS11.narrative_overall is missing or blank where DS11.narrative_type = 120 (by DS03.WBS_ID_CA &amp; DS11.WBS_ID).</message>
  <grouping>WBS_ID_CA</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030074</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsVACMissingDS11RCNarrUnfav] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		Checks for any CA's where VAC > the unfavorable threshold and there is 
		no DS11 overall narrative.

		Specifically, the check is: |DS03.VAC (DB - EAC)| > |threshold_cost_VAC_dollar_unfav| 
		where DS11.narrative_overall where DS11.narrative_type = 120 is blank (by CA WBS ID).

		To do this, we first get the unfavorable threshold in DS07.
		
		Then, load VAC DS03 data into a cte, CAVAC, by WBS ID,
		filtering for any WBS IDs that don't have a DS11.narrative_overall where DS11.narrative_type = 120.

		Lastly, get rows by comparing the VACs to the threshold.
	*/
	with threshold as (
		SELECT ABS(ISNULL(threshold_cost_VAC_dollar_unfav,0)) thrshld
		FROM DS07_IPMR_header 
		WHERE upload_ID = @upload_ID
	), CAVAC as (
		SELECT 
			WBS_ID_CA CAWBS, 
			ABS(SUM(BCWSi_dollars) - SUM(ACWPi_dollars) - SUM(ETCi_dollars)) VAC
		FROM 
			DS03_cost C
		WHERE 
				upload_ID = @upload_ID
			AND WBS_ID_CA NOT IN (
				SELECT WBS_ID 
				FROM DS11_variance
				WHERE upload_ID = @upload_ID AND narrative_overall IS NOT NULL AND narrative_type = 120
			)
		GROUP BY WBS_ID_CA
	)


	SELECT 
		C.*
	FROM
		DS03_cost C INNER JOIN CAVAC V ON C.WBS_ID_CA = V.CAWBS
	WHERE
			upload_ID = @upload_ID
		AND V.VAC > (SELECT TOP 1 thrshld FROM threshold)
)