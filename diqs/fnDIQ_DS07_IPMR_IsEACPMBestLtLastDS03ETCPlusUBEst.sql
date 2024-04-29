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
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>PM EAC Best Date Misaligned with Cost Estimates</title>
  <summary>Is the PM EAC Best date earlier than the last recorded ETC plus estimated UB?</summary>
  <message>EAC_PM_best_date &lt; last DS03.period_date where ETCi &gt; 0 (hours, dollars, or FTEs) + DS07.UB_EST_days.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070303</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsEACPMBestLtLastDS03ETCPlusUBEst] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function checks to see if the EAC PM best < the last recorded ETCi + UB EST.
		Because the test is on calendar days, we need to add a weekend factor to the UB EST,
		which adds 2 days for every 5 in UB_EST_Days.
		So we divide UB_EST_Days by five, multiply by two, and then add the value back to UB_Est_days
		to do the final comparison.
	*/

	with LastETCi as (
		SELECT MAX(period_date) LastPrd
		FROM DS03_cost 
		WHERE upload_ID = @upload_ID AND (ETCi_dollars > 0 OR ETCi_FTEs > 0 OR ETCi_hours > 0)
	), UBEstWkndFactor as (
		SELECT (ISNULL(UB_est_days,0) / 5) * 2 WkndF
		FROM DS07_IPMR_header 
		WHERE upload_ID = @upload_ID
	)

	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND EAC_PM_best_date < DATEADD(day, (SELECT TOP 1 WkndF FROM UBEstWkndFactor), (SELECT TOP 1 LastPrd FROM LastETCi))
)