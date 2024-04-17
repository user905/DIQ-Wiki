/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>Indirect Missing From Project</title>
  <summary>Is Indirect missing from this project?</summary>
  <message>No rows found where BCWSi &gt; 0 (Dollars, Hours, or FTEs) and EOC = Indirect or is_indirect = Y.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1030111</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsIndirectBCWSMissingFromProject] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Indirect as (
		SELECT	*
		FROM	DS03_cost
		WHERE	upload_ID = @upload_id
			AND	(BCWSi_Dollars > 0 OR BCWSi_Hours > 0 OR BCWSi_FTEs > 0)
			AND (EOC = 'Indirect' OR is_indirect = 'Y')
	)
	SELECT *
	FROM DummyRow_Get(@upload_id)
	WHERE NOT EXISTS (SELECT * FROM Indirect)
)