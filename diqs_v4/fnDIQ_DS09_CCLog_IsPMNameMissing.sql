/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS09 CC Log</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Missing PM</title>
  <summary>Is the PM name missing on this CC log entry?</summary>
  <message>PM null or blank.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1090447</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS09_CCLog_IsPMNameMissing] (
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
		AND TRIM(ISNULL(PM,'')) = ''
)