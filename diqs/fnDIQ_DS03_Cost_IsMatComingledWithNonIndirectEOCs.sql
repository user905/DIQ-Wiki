/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Material Found Alongside Non-Overhead EOCs</title>
  <summary>Does this WP/PP comingle Material with other EOC types (excluding Indirect)?</summary>
  <message>EOC = Material &amp; Subcontract, ODC, or Labor by WBS_ID_WP.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030095</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsMatComingledWithNonIndirectEOCs] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with NonMaterial AS (
		SELECT WBS_ID_WP WPID
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC NOT IN ('Material','Indirect') AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		GROUP BY WBS_ID_WP
	)
	SELECT C.* 
	FROM DS03_Cost C LEFT OUTER JOIN NonMaterial N ON C.WBS_ID_WP = N.WPID
	WHERE	upload_ID = @upload_ID AND EOC = 'Material' AND N.WPID IS NOT NULL
)