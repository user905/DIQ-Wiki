/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS17 WBS EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>WBS &amp; EOC Combo Missing in Cost</title>
  <summary>Is this WBS_ID / EOC combo missing in the cost processor?</summary>
  <message>Combo of WBS_ID_WP &amp; EOC missin in DS03.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9170579</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS17_WBS_EU_IsWBSAndEOCComboNotInDS03] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostWBS as (
		SELECT CONCAT(WBS_ID_WP,'-', EOC) WBSEOC
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
		GROUP BY CONCAT(WBS_ID_WP,'-', EOC) 
	)
	SELECT 
		*
	FROM 
		DS17_WBS_EU
	WHERE 
			upload_ID = @upload_ID
		AND CONCAT(WBS_ID,'-', EOC) NOT IN (SELECT WBSEOC FROM CostWBS)
)