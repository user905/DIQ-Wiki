/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Labor Missing Estimates</title>
  <summary>Is this Labor missing Estimated Dollars, Hours, or FTEs?</summary>
  <message>EOC = Labor with ETCi &lt;&gt; 0 for either Dollars, Hours, or FTEs, but where at least one other ETCi = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030091</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsLaborMissingETCDollarsHoursOrFTEs] (
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
		AND (ETCi_dollars <> 0 OR ETCi_FTEs <> 0 OR ETCi_hours <> 0)
		AND (ETCi_dollars = 0 OR ETCi_FTEs = 0 OR ETCi_hours = 0)
)