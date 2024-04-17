/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>AUW Dollar Change Exceeds NTE</title>
  <summary>Does this AUW dollar change above the NTE?</summary>
  <message>AUW = Y &amp; dollars_delta &gt; NTE_dollars_delta.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1100451</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_AreAUWDollarsGtNTE] (
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
		AND AUW = 'Y'
		AND dollars_delta > 0
		AND NTE_dollars_delta < dollars_delta
)