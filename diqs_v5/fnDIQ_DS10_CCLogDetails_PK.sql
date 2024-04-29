/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate CC Log Detail Transaction</title>
  <summary>Is the transaction duplicated by transaction &amp; CC log ID?</summary>
  <message>Count of transaction_ID &amp; CC_log_ID combo &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1100478</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT transaction_id, CC_log_ID
		FROM DS10_CC_log_detail
		WHERE upload_ID = @upload_ID
		GROUP BY transaction_id, CC_log_ID
		HAVING COUNT(*) > 1
	)
	SELECT 
		C.*
	FROM 
		DS10_CC_log_detail C INNER JOIN Dupes D ON C.transaction_ID = D.transaction_ID
												AND C.CC_log_ID = D.CC_log_ID
	WHERE 
		upload_ID = @upload_ID
)