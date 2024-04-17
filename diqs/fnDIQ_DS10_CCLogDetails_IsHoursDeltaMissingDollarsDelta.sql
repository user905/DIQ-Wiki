/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Hours Delta without Dollars</title>
  <summary>Are there hours on this transaction but no dollars?</summary>
  <message>hours_delta &lt;&gt; 0 &amp; dollars_delta = 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1100467</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsHoursDeltaMissingDollarsDelta] (
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
	AND hours_delta <> 0
	AND ISNULL(dollars_delta,0)=0
)