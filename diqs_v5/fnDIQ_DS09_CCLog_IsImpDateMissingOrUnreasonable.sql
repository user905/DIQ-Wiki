/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS09 CC Log</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Implementation Date Missing or Unreasonable</title>
  <summary>Is the implementation date missing or is it considerably after the approved date?</summary>
  <message>implementation_date is missing or &gt; the next DS03.period_date after the current DS09.approved_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9090445</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS09_CCLog_IsImpDateMissingOrUnreasonable] (
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
		AND (
			implementation_date IS NULL OR
			implementation_date > (
				SELECT period_date
				FROM (
					SELECT period_date, ROW_NUMBER() OVER (ORDER BY period_date ASC) AS row_num
					FROM DS03_cost
					WHERE upload_ID = @upload_ID AND period_date >= approved_date
				) subQ
				WHERE row_num = 2
			)
		)
)