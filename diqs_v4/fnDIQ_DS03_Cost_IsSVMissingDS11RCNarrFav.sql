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
  <title>SV without Root Cause Narrative (Favorable)</title>
  <summary>Is a root cause narrative missing for this CA where the SV is tripping the favorable dollar threshold?</summary>
  <message>DS03.SVc (|BCWP - BCWS|) &gt; |DS07.threshold_schedule_cum_dollar_fav| &amp; DS11.narrative_RC_SVc is missing or blank (by DS03.WBS_ID_CA &amp; DS11.WBS_ID).</message>
  <grouping>WBS_ID_CA</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030316</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsSVMissingDS11RCNarrFav] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		Checks for any CA's where SV > the favorable threshold and there is 
		no DS11 SV narrative.

		Specifically, the check is: |DS03.SV (BCWP - BCWS)| > |threshold_schedule_cum_dollar_fav| 
		where DS11.narrative_RC_SVc is blank (by CA WBS ID).

		To do this, we first get the favorable threshold in DS07.
		
		Then, load SVcum DS03 data into a cte, CASV, by WBS ID,
		filtering for any WBS IDs that don't have a DS11.narrative_RC_SVc.

		Lastly, get rows by comparing the SVs to the threshold.
	*/
	with threshold as (
		SELECT ABS(ISNULL(threshold_schedule_cum_dollar_fav,0)) thrshld
		FROM DS07_IPMR_header 
		WHERE upload_ID = @upload_ID
	), VARs as (
		SELECT WBS_ID 
		FROM DS11_variance
		WHERE upload_ID = @upload_ID AND narrative_RC_SVc IS NOT NULL
	), CASV as (
		SELECT WBS_ID_CA CAWBS, ABS(SUM(BCWPi_dollars) - SUM(BCWSi_dollars)) SV
		FROM DS03_cost C
		WHERE	upload_ID = @upload_ID
			AND WBS_ID_CA NOT IN (SELECT WBS_ID FROM VARs)
		GROUP BY WBS_ID_CA
	)


	SELECT 
		C.*
	FROM
		DS03_cost C INNER JOIN CASV SV ON C.WBS_ID_CA = SV.CAWBS
	WHERE
			upload_ID = @upload_ID
		AND SV.SV > (SELECT TOP 1 thrshld FROM threshold)
		AND (SELECT COUNT(*) FROM VARs) > 0 --test only if DS11 has records
)