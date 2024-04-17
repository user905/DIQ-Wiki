/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>PM EAC Dollars Out of Order</title>
  <summary>Are the PM EAC dollars increasing in an order other than best, likely, worst?</summary>
  <message>EAC_PM_best_dollars &gt;= EAC_PM_likely_dollars OR EAC_PM_likely_dollars &gt;= EAC_PM_worst_dollars.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1070269</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_ArePMEACDollarsOutOfOrder] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND (
			EAC_PM_best_dollars >= EAC_PM_likely_dollars OR 
			EAC_PM_likely_dollars >= EAC_PM_worst_dollars
		)
)