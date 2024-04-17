/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Dollars Delta Missing</title>
  <summary>Is the dollars delta for this transaction missing or zero?</summary>
  <message>dollars_delta missing or 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1100466</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsDollarsDeltaMissing] (
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
		AND ISNULL(dollars_delta,0) = 0
)