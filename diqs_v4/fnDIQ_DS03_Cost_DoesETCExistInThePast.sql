/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Estimates in the Past</title>
  <summary>Are there estimates still showing in previous periods?</summary>
  <message>ETCi &lt;&gt; 0 (Dollars, Hours, or FTEs) where period_date &lt;= CPP_Status_Date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030064</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoesETCExistInThePast] (
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
		AND (ETCi_dollars <> 0 OR ETCi_FTEs <> 0 OR ETCi_hours <> 0)
		AND period_date <= CPP_status_date 
)