/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>Overhead Not Mingled With Other EOCs</title>
  <summary>Does this SLPP, PP, or WP have only Overhead EOCs?</summary>
  <message>SLPP, PP, or WP with only Overhead.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030094</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsOverheadWorkMissingOtherEOCTypes] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with NonOverhead AS (
		SELECT WBS_ID_CA CAID, ISNULL(WBS_ID_WP,'') WPID
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC <> 'Overhead'
		GROUP BY WBS_ID_CA, WBS_ID_WP
	), WBS as (
		SELECT WBS_ID, type
		FROM DS01_WBS
		WHERE upload_ID = @upload_ID
	)
	SELECT 
		C.* 
	FROM 
		DS03_Cost C LEFT OUTER JOIN NonOverhead N 	ON C.WBS_ID_CA = N.CAID 
													AND ISNULL(C.WBS_ID_WP,'') = N.WPID
	WHERE
			upload_ID = @upload_ID
		AND EOC = 'Overhead'
		AND N.CAID IS NULL
		AND (
			WBS_ID_WP IN (SELECT WBS_ID FROM WBS WHERE type IN ('WP','PP')) OR
			WBS_ID_CA IN (SELECT WBS_ID FROM WBS WHERE type = 'SLPP')
		)
)