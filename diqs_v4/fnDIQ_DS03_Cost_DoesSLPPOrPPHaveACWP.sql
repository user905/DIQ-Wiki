/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>SLPP or PP with Actuals</title>
  <summary>Does this SLPP or PP have actuals?</summary>
  <message>SLPP or PP found with ACWPi &lt;&gt; 0 (Dollars, Hours, or FTEs).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030071</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesSLPPOrPPHaveACWP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with ToTest (WBSID) AS (
		SELECT WBS_ID
		FROM DS01_WBS
		WHERE upload_ID = @upload_ID AND type in ('SLPP','PP')
	)
	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND (ACWPi_dollars <> 0 OR ACWPi_FTEs <> 0 OR ACWPi_hours <> 0)
		AND (
			(TRIM(ISNULL(WBS_ID_WP,'')) <> '' AND WBS_ID_WP IN (SELECT WBSID FROM ToTest)) OR
			(TRIM(ISNULL(WBS_ID_WP,'')) = '' AND WBS_ID_CA IN (SELECT WBSID FROM ToTest)) OR
			EVT = 'K'
		)
)