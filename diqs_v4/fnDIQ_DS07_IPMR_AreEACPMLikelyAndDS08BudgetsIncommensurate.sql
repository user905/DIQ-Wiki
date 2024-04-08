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
  <type>Performance</type>
  <title>EAC PM Likely Incommensurate with WAD BAC</title>
  <summary>Is the EAC PM likely considerably different from the BAC as reported in the WADs?</summary>
  <message>|(EAC_PM_likey_dollars - sum of DS08.budget_[EOC]_dollars) / sum of DS08.budget_[EOC]_dollars)| &gt; .1 (Or delta &gt; $1,000 where either value = 0).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070362</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_AreEACPMLikelyAndDS08BudgetsIncommensurate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(

	/*
		Checks to see whether the EAC PM likely is roughly within 10% of the WAD BAC for the project.
		
		Specifically, the formula is:
		|(EAC_PM_likey_dollars - SUM(DS08.budget_dollars)) / SUM(DS08.budget_dollars)| > .1 

		If DS08.budget_dollars = 0 or Eac_PM_likely_dollars = 0, 
		then flag if the delta is greater than $1000.
	*/
	with BAC as (
		SELECT SUM(
			ISNULL(budget_labor_dollars,0) + 
			ISNULL(budget_material_dollars,0) + 
			ISNULL(budget_ODC_dollars,0) +
			ISNULL(budget_overhead_dollars,0) + 
			ISNULL(budget_subcontract_dollars,0)
		) BAC
		FROM DS08_WAD
		WHERE upload_ID = @upload_ID
	)

	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND (
			(	--if either is zero, flag if either is more than $1000.
				(ISNULL(EAC_PM_likely_dollars,0) = 0 OR (SELECT TOP 1 BAC FROM BAC) = 0) 
			AND ABS(ISNULL(EAC_PM_likely_dollars,0) - (SELECT TOP 1 BAC FROM BAC)) > 1000)
				--otherwise, flag if the difference is more than 10%.
			OR ABS((ISNULL(EAC_PM_likely_dollars,0) - (SELECT TOP 1 BAC FROM BAC)) / NULLIF((SELECT TOP 1 BAC FROM BAC),0)) > .1
		)
)