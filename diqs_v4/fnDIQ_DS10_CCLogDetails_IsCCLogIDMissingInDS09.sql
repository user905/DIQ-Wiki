/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CC Log ID Missing in CC Log</title>
  <summary>Is the CC Log Id for this transaction missing in the CC Log table?</summary>
  <message>CC_log_ID not in DS09.CC_log_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9100462</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsCCLogIDMissingInDS09] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS10_CC_log_detail
	WHERE 
			upload_ID = @upload_ID
		AND CC_log_ID NOT IN (SELECT CC_log_ID FROM DS09_CC_log WHERE upload_ID = @upload_ID)
)