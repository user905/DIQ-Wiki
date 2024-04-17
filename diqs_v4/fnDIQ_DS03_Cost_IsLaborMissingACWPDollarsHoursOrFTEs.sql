/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Labor Missing Actuals</title>
  <summary>Is this Labor missing Actual Dollars, Hours, or FTEs?</summary>
  <message>EOC = Labor with ACWPi &lt;&gt; 0 for either Dollars, Hours, or FTEs, but where at least one other ACWPi = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030088</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsLaborMissingACWPDollarsHoursOrFTEs] (
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
		AND (ACWPi_dollars <> 0 OR ACWPi_FTEs <> 0 OR ACWPi_hours <> 0)
		AND (ACWPi_dollars = 0 OR ACWPi_FTEs = 0 OR ACWPi_hours = 0)
)