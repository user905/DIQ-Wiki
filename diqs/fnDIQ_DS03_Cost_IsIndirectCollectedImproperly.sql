/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Improper Collection of Indirect</title>
  <summary>Is indirect collected at the CA level or via the EOC field (rather than using is_indirect)?</summary>
  <message>EOC = Indirect, is_indirect missing, or is_indirect = Y/N found at the CA level (where WBS_ID_WP is blank).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1030115</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsIndirectCollectedImproperly] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT *
	FROM DummyRow_Get(@upload_ID)
	WHERE EXISTS (
		SELECT * 
		FROM DS03_cost
		WHERE upload_ID = @upload_id
			AND (
					is_indirect IS NULL  --is_indirect is unused
				OR (TRIM(ISNULL(WBS_ID_WP,'')) = '' AND ISNULL(is_indirect,'') <> '') --CA data with is_indirect
				OR EOC = 'Indirect' --indirect in the EOC column
			)
	)
)