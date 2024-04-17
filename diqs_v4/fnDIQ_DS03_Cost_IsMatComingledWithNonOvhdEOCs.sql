/*
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