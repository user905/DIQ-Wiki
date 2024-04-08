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
  <severity>WARNING</severity>
  <title>PMB + MR &lt;&gt; CBB + Overrun</title>
  <summary>Are the PM and MR equal to something other than CBB plus overrun?</summary>
  <message>CBB_dollars != sum of DS08.budget_dollars + UB_bgt + MR_bgt + MR_rpg - sum DS03.BAC_rpg.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070369</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_ArePMBAndMRNotEqToCBB] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		Checks to see whether CBB <> PMB + MR - overrun. 
		
		Specifically, the comparison is CBB_dollars != SUM(DS08.budget_dollars) + UB_bgt + MR_bgt + MR_rpg - SUM(DS03.BAC_rpg).
		(Note: If DS08 is empty, we use DS03 BAC instead)

		But to add a $100 buffer, we rearrange the calculation and use absolute value:
		|CBB_dollars - SUM(DS08.budget_dollars) - UB_bgt - MR_bgt - MR_rpg + SUM(DS03.BAC_rpg)| > 100.
	*/
	with WADBAC as (
		SELECT 
			SUM(ISNULL(budget_labor_dollars,0) + 
				ISNULL(budget_material_dollars,0) + 
				ISNULL(budget_ODC_dollars,0) + 
				ISNULL(budget_overhead_dollars,0) + 
				ISNULL(budget_subcontract_dollars,0)
			) as BAC
		FROM DS08_WAD
		WHERE upload_ID = @upload_ID
	), CostBAC as (
		SELECT SUM(ISNULL(BCWSi_dollars,0)) BAC
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
	), Overrun as (
		SELECT SUM(ISNULL(BAC_Rpg,0)) Overrun
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
	)

	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND ABS(ISNULL(CBB_dollars,0) - 
				COALESCE((SELECT TOP 1 BAC FROM WADBAC),(SELECT TOP 1 BAC FROM CostBAC)) - 
				ISNULL(UB_bgt_dollars,0) - 
				ISNULL(MR_bgt_dollars,0) - 
				ISNULL(MR_rpg_dollars,0) + 
				(SELECT TOP 1 Overrun FROM Overrun)
			) > 100
)