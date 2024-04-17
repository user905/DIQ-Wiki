/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS12 Variance CAL</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Transaction ID Missing</title>
  <summary>Is the transaction ID missing?</summary>
  <message>transaction_ID blank or missing.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1120501</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS12_VAR_CAL_IsTransactionIDMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM 
		DS12_variance_CAL
	WHERE 
			upload_ID = @upload_ID 
		AND TRIM(ISNULL(transaction_ID,'')) = ''
)