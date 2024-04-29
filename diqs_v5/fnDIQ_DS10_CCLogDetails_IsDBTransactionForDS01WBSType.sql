/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>DB Transaction On Non-CA, SLPP, PP, or WP</title>
  <summary>Is this DB transaction being applied to something other than a CA, SLPP, PP, or WP?</summary>
  <message>category = DB &amp; DS01.type &lt;&gt; CA, SLPP, PP, or WP.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9100463</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsDBTransactionForDS01WBSType] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		L.*
	FROM 
		DS10_CC_log_detail L INNER JOIN DS01_WBS W ON L.WBS_ID = W.WBS_ID
	WHERE 
		L.upload_ID = @upload_ID
	AND W.upload_ID = @upload_ID
	AND category = 'DB'
	AND W.type NOT IN ('CA','SLPP','PP','WP')
)