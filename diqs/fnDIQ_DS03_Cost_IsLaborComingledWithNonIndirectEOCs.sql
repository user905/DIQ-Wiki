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
  <title>Labor Found Alongside Non-Indirect EOC</title>
  <summary>Does this WP/PP mingle Labor with other EOC types (excluding Indirect)?</summary>
  <message>EOC = Labor &amp; Material, Subcontract, or ODC by WBS_ID_WP.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030117</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsLaborComingledWithNonIndirectEOCs] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	/*
		October 2023: Because of DID v5, this has replaced fnDIQ_DS03_Cost_IsSubKComingledWithNonOvhdtEOCs.

		This function looks for WP/PPs with a mix of Labor EOC and any 
		EOC other than Indirect (e.g. Material, Subcontract, ODC). 

		Step 1. Create cte, NonLbr, and load it with WP/PPs where EOC <> Labor OR Indirect
		Step 2. Left join NonLbr to cost data that has been filtered for EOC = Labor.
		
		Any join is a flag.

		Note: We do not use is_indirect = Y for treating rows like indirect (E.g. Treating a row with EOC = Material and is_indirect = Y as Indirect).
		We treat all rows as what their EOC says they are.
	*/

	with NonLbr AS (
		SELECT WBS_ID_WP WPID
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC NOT IN ('Labor','Indirect') AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		GROUP BY WBS_ID_WP
	)

	SELECT C.* 
	FROM DS03_Cost C LEFT OUTER JOIN NonLbr N ON C.WBS_ID_WP = N.WPID
	WHERE	upload_ID = @upload_ID AND EOC = 'Labor' AND N.WPID IS NOT NULL
)