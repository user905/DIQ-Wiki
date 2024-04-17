/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS09 CC Log</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>BCP Change Control Without BCP</title>
  <summary>Does this BCP change control log entry exist without a BCP in the schedule?</summary>
  <message>type = BCP &amp; count = 0 where DS04.milestone_level between 131 &amp; 135.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9090449</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS09_CCLog_DoBCPTransactionsExistWithoutDS04BCPs] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with BCPCount as (
		SELECT COUNT(*) Count
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND milestone_level BETWEEN 131 AND 135
	)
	SELECT 
		*
	FROM
		DS09_CC_log
	WHERE
			upload_ID = @upload_ID  
		AND [type] = 'BCP'
		AND (SELECT TOP 1 Count FROM BCPCount) = 0
)