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
  <title>CBB Misaligned with PMB, MR, &amp; Overrun</title>
  <summary>Is the stated CBB value in the IPMR header plus the cost Overrun equal to the PMB plus MR?</summary>
  <message>CBB_dollars &lt;&gt; PMB (DS03.DB + DS07.UB_bgt) + MR_bgt + MR_rpg - Overrun (Sum of DS03.BAC_rpg).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9070351</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsCBBNEqToPMBPlusMRMinusOverrun] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function checks whether CBB + overrun = PMB + MR.
		In practice, this becomes some combo of the following: 
		DS07.CBB_dollars <> MR_Rpg + MR_Bgt + DS03.DB (SUM(DS03.BCWSi_dollars)) + DS07.UB_Bgt - SUM(DS03.BAC_rpg)
	*/

	with Cost as (
		SELECT SUM(BCWSi_dollars) DB, SUM(ISNULL(BAC_rpg,0)) Rpg
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
	)

	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND CBB_dollars <> (SELECT DB FROM Cost) + ISNULL(UB_bgt_dollars,0) + --PMB
							ISNULL(MR_bgt_dollars,0) + ISNULL(MR_rpg_dollars,0) - --MR
							(SELECT Rpg FROM Cost) --overrun
)