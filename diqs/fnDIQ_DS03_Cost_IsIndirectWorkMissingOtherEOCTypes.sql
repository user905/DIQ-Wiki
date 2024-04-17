/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Indirect Not Mingled With Other EOCs</title>
  <summary>Does this CA, SLPP, PP, or WP have only Indirect EOCs?</summary>
  <message>CA, SLPP, PP, or WP with only Indirect.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030098</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsIndirectWorkMissingOtherEOCTypes] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with NonIndirect AS (
		SELECT WBS_ID_CA CAID, ISNULL(WBS_ID_WP,'') WPID
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC <> 'Indirect' AND ISNULL(is_indirect,'') <> 'Y'
		GROUP BY WBS_ID_CA, ISNULL(WBS_ID_WP,'')
	)
	SELECT C.* 
	FROM DS03_Cost C LEFT OUTER JOIN NonIndirect N 	ON C.WBS_ID_CA = N.CAID AND ISNULL(C.WBS_ID_WP,'') = N.WPID
	WHERE	upload_ID = @upload_ID
		AND (EOC = 'Indirect' OR is_indirect = 'Y')
		AND N.CAID IS NULL
)