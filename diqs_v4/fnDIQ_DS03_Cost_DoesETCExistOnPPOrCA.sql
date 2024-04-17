/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Estimates on PP or CA</title>
  <summary>Are there estimates on this CA or PP?</summary>
  <message>CA or PP with ETCi &lt;&gt; 0 (Dollars, Hours, or FTEs).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030065</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesETCExistOnPPOrCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with ToTest (WBSID) AS (
		SELECT WBS_ID
		FROM DS01_WBS
		WHERE upload_ID = @upload_ID AND type in ('CA','PP')
	)
	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND (ETCi_dollars <> 0 OR ETCi_FTEs <> 0 OR ETCi_hours <> 0)
		AND (
			(TRIM(ISNULL(WBS_ID_WP,'')) <> '' AND WBS_ID_WP IN (SELECT WBSID FROM ToTest)) OR
			(TRIM(ISNULL(WBS_ID_WP,'')) = '' AND WBS_ID_CA IN (SELECT WBSID FROM ToTest))
		)
)