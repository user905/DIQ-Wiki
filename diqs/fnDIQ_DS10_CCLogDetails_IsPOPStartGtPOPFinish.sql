/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>POP Start After POP Finish</title>
  <summary>Is the POP start on this transaction later than the POP finish?</summary>
  <message>POP_start_date &gt; POP_finish_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1100474</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsPOPStartGtPOPFinish] (
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
	AND POP_start_date > POP_finish_date
)