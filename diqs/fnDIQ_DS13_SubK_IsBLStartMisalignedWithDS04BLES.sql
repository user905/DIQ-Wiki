/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS13 Subcontract</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>BL Start Misaligned with Baseline Schedule</title>
  <summary>Is the baseline start date misaligned with the early start in the baseline schedule?</summary>
  <message>BL_start_date &lt;&gt; DS04.ES_date where schedule_type = BL (by task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9130525</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS13_SubK_IsBLStartMisalignedWithDS04BLES] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		SK.*
	FROM 
		DS13_subK SK INNER JOIN DS04_schedule S ON SK.task_ID = S.task_ID
	WHERE 
			SK.upload_ID = @upload_ID 
		AND S.upload_ID = @upload_ID
		AND SK.BL_start_date <> S.ES_date
		AND schedule_type = 'BL'
)