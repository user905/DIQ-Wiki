/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS13 Subcontract</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Missing BL Start</title>
  <summary>Is the baseline start date missing?</summary>
  <message>BL_start_date is missing.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1130526</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS13_SubK_IsBLStartMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM 
		DS13_subK
	WHERE 
			upload_ID = @upload_ID 
		AND BL_start_date IS NULL
)