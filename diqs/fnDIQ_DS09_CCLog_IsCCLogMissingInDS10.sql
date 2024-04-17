/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS09 CC Log</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CC Log ID Missing in CC Log Detail</title>
  <summary>Is this CC Log ID missing in the log detail?</summary>
  <message>CC_log_ID missing in DS10.CC_log_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9090442</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS09_CCLog_IsCCLogMissingInDS10] (
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
		AND CC_log_ID NOT IN (
			SELECT CC_log_ID
			FROM DS10_CC_log_detail
			WHERE upload_ID = @upload_ID
		)
)