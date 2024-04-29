/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS13 Subcontract</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Actual Finish Misaligned with Forecast Schedule</title>
  <summary>Is the actual finish date misaligned with the actual finish in the forecast schedule?</summary>
  <message>AF_date &lt;&gt; DS04.AF_date where schedule_type = FC (by task_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9130516</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS13_SubK_IsAFDateMisalignedWithDS04] (
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
		AND SK.AF_date <> S.AF_date
)