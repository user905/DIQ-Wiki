/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>AUW Change Missing Dollars Delta</title>
  <summary>Is this change to AUW missing a dollar amount?</summary>
  <message>AUW = Y &amp; dollars_delta = null or zero.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1100461</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsAUWChangeMissingDollars] (
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
		AND (ISNULL(dollars_delta,0) = 0)
)