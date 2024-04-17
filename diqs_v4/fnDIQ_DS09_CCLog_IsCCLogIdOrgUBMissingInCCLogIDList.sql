/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS09 CC Log</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Original UB CC Log ID Missing in CC Log ID List</title>
  <summary>Is this Original UB CC Log ID missing in the CC Log ID list?</summary>
  <message>CC_log_ID_original_UB missing in CC_log_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1090441</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS09_CCLog_IsCCLogIdOrgUBMissingInCCLogIDList] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS09_CC_log
	WHERE
			upload_ID = @upload_ID  
		AND CC_log_ID_original_UB NOT IN (
			SELECT CC_log_ID
			FROM DS09_CC_log
			WHERE upload_ID = @upload_ID
		)
)