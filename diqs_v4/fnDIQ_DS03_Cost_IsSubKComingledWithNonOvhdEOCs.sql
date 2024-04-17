/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Subcontract Comingled with Non-Overhead EOCs</title>
  <summary>Does this SLPP, PP, or WP mingle Subcontract with other EOC types (excluding Overhead)?</summary>
  <message>EOC = Subcontract &amp; Material, ODC, or Labor by WBS_ID_WP or WBS_ID_CA.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030110</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsSubKComingledWithNonOvhdEOCs] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with NonSubcontract AS (
		SELECT WBS_ID_CA CAID, ISNULL(WBS_ID_WP,'') WPID
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC NOT IN ('Subcontract','Overhead')
		GROUP BY WBS_ID_CA, WBS_ID_WP
	)
	SELECT 
		C.* 
	FROM 
		DS03_Cost C LEFT OUTER JOIN NonSubcontract N ON C.WBS_ID_CA = N.CAID 
													AND ISNULL(C.WBS_ID_WP,'') = N.WPID
	WHERE
			upload_ID = @upload_ID
		AND EOC = 'Subcontract'
		AND N.CAID IS NOT NULL
		AND (
			WBS_ID_WP IN (SELECT WBS_ID FROM DS01_WBS WHERE upload_ID = @upload_ID AND type IN ('WP','PP')) OR
			WBS_ID_CA IN (SELECT WBS_ID FROM DS01_WBS WHERE upload_ID = @upload_ID AND type = 'SLPP')
		)
)