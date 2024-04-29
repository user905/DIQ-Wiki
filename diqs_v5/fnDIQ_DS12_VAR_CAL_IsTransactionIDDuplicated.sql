/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS12 Variance CAL</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Duplicate Transaction ID</title>
  <summary>Is the transaction ID on this corrective action duplicated?</summary>
  <message>Count of transaction_ID &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1120500</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS12_VAR_CAL_IsTransactionIDDuplicated] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM 
		DS12_variance_CAL DS12
	WHERE 
			DS12.upload_ID = @upload_ID 
		AND DS12.transaction_ID IN (
			SELECT transaction_ID 
			FROM DS12_variance_CAL 
			WHERE upload_ID = @upload_ID 
			GROUP BY transaction_ID 
			HAVING COUNT(*) > 1
		)
)