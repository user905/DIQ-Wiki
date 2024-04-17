/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS13 Subcontract</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Profit Fee Earned Dollars Missing</title>
  <summary>Are profit fee earned dollars missing on this subcontract?</summary>
  <message>profit_fee_earned_dollars missing or 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1130511</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS13_SubK_AreProfitFeeEarnedDollarsMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM 
		DS13_subK
	WHERE 
			upload_ID = @upload_ID 
		AND ISNULL(profit_fee_earned_dollars,0) = 0
)