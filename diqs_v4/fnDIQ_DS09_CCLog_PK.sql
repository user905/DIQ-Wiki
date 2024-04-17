/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS09 CC Log</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate CC Log Entry</title>
  <summary>Is this CC Log entry duplicated by CC Log ID &amp; Supplement ID?</summary>
  <message>Count of CC_log_ID &amp; CC_log_ID_supplement combo &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1090440</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS09_CCLog_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT CC_log_ID LogID, ISNULL(CC_log_ID_supplement,'') Supp
		FROM DS09_CC_log
		WHERE upload_ID = @upload_ID
		GROUP BY CC_log_ID, ISNULL(CC_log_ID_supplement,'')
		HAVING COUNT(*) > 1
	)
	SELECT 
		L.*
	FROM
		DS09_CC_log L INNER JOIN Dupes D ON L.CC_log_ID = D.LogID 
										AND ISNULL(L.CC_log_ID_supplement,'') = D.Supp
	WHERE
		upload_ID = @upload_ID  
)