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
  <title>Material Comingled with Non-Overhead EOCs</title>
  <summary>Does this SLPP, PP, or WP comingle Material with other EOC types (excluding Overhead)?</summary>
  <message>EOC = Material &amp; Subcontract, ODC, or Labor by WBS_ID_WP or WBS_ID_CA.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030092</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsMatComingledWithNonOvhdEOCs] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for SLPPs, PPs, or WPs with a mix of Material EOC and any 
		EOC other than Overhead (e.g. subcontract, ODC, Labor). 

		It creates a cte, NonMaterial, and loads it with CA & WP IDs where EOC <> Material OR Overhead.
	*/

	with NonMaterial AS (
		SELECT WBS_ID_CA CAID, ISNULL(WBS_ID_WP,'') WPID
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC NOT IN ('Material','Overhead')
		GROUP BY WBS_ID_CA, WBS_ID_WP
	), WBS as (
		SELECT WBS_ID, type
		FROM DS01_WBS
		WHERE upload_ID = @upload_ID
	)

	/*
		It then left joins that CTE to cost data that has been filtered for EOC = Material.
		Any join (NonOverhead.CAID is NOT null) is a trip.

		The subselects at the bottom are to filter for WP/PP/SLPP types only.
	*/

	SELECT 
		C.* 
	FROM 
		DS03_Cost C LEFT OUTER JOIN NonMaterial N ON C.WBS_ID_CA = N.CAID 
												  AND ISNULL(C.WBS_ID_WP,'') = N.WPID
	WHERE
			upload_ID = @upload_ID
		AND EOC = 'Material'
		AND (
				WBS_ID_WP IN (SELECT WBS_ID FROM WBS WHERE type IN ('WP','PP'))
			OR WBS_ID_CA IN (SELECT WBS_ID FROM WBS WHERE type = 'SLPP')
		)
)