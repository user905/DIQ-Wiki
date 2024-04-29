/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS12 Variance CAL</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate VAR CAL Entry</title>
  <summary>Is this VAR CAL entry duplicated by CAL ID &amp; transaction ID?</summary>
  <message>Count of CAL_ID &amp; transaction_ID combo &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1120502</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS12_VAR_CAL_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT CAL_ID, ISNULL(transaction_ID,'') transaction_ID
		FROM DS12_variance_CAL
		WHERE upload_ID = @upload_ID
		GROUP BY CAL_ID, ISNULL(transaction_ID,'')
		HAVING COUNT(*) > 1
	)
	SELECT
		C.*
	FROM 
		DS12_variance_CAL C INNER JOIN Dupes D ON C.CAL_ID = D.CAL_ID 
											  AND ISNULL(C.transaction_ID,'') = D.transaction_ID
	WHERE 
		upload_ID = @upload_ID
)