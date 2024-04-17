/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>DB Transaction Missing WBS ID</title>
  <summary>Is this DB transaction missing a WBS ID?</summary>
  <message>category = DB &amp; WBS_ID is missing or blank.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1100464</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsDBTransactionMissingWBSID] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT transaction_id
		FROM DS10_CC_log_detail
		WHERE upload_ID = @upload_ID
		GROUP BY transaction_id
		HAVING COUNT(*) > 1
	)
	SELECT 
		*
	FROM 
		DS10_CC_log_detail
	WHERE 
		upload_ID = @upload_ID
	AND category = 'DB'
	AND TRIM(ISNULL(WBS_ID,'')) = ''
)