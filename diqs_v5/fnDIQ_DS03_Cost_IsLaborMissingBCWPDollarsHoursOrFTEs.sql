/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Labor Missing Performance</title>
  <summary>Is this Labor missing Performance Dollars, Hours, or FTEs?</summary>
  <message>EOC = Labor with BCWPi &lt;&gt; 0 for either Dollars, Hours, or FTEs, but where at least one other BCWPi = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030089</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsLaborMissingBCWPDollarsHoursOrFTEs] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND EOC = 'Labor'
		AND ISNULL(is_indirect,'') <> 'Y'
		AND (BCWPi_dollars <> 0 OR BCWPi_FTEs <> 0 OR BCWPi_hours <> 0)
		AND (BCWPi_dollars = 0 OR BCWPi_FTEs = 0 OR BCWPi_hours = 0)
)